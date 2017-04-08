require "dry-initializer"
require "tram/policy/errors"
require "tram/policy/validation_error"

module Tram
  class Policy
    extend Dry::Initializer::Mixin

    singleton_class.send(:alias_method, :[], :new)

    attr_reader :errors

    class << self
      # Class-level method to add validators
      # (they will be invoked in the same order as defined)
      #
      #   validate :title_presence
      def validate(method)
        @validators = validators.push(method)
      end

      def validators
        @validators || Array.new
      end
    end

    def initialize(*args, options)
      super
      @errors = Tram::Policy::Errors.new(self)
      run_validations!
    end

    # Return true if no errors exist
    def valid?
      errors.clear
      run_validations!

      @errors.empty?
    end

    # Return true if some error exists
    def invalid?
      !valid?
    end

    # Raises Tram::Policy::ValidationError exception if some error exists
    def validate!
      raise Tram::Policy::ValidationError.new(self) if invalid?
    end

    # Use for RSpec matcher be_invalid_at
    #
    # Checks at once:
    #
    # * that an error is added to the policy
    # * that the error has given tags
    # * that the error is translated to every available locale
    #
    # Return description for the essence of the failure if policy is invalid
    # Return false if policy is valid
    def invalid_at?(tags)
      errors.clear
      run_validations!

      reasons = []

      filtered_errors = errors.select do |error|
        tags.all? {|tag, value| error.tags[tag].to_s == value.to_s}
      end
      reasons.push("Policy is invalid: #{filtered_errors.map(&:message).join(', ')}") if filtered_errors.any?

      missed_translations = filtered_errors.map(&:missed_translations).flatten.compact
      reasons.push("Missed translations: #{missed_translations.join(', ')}") if missed_translations.any?

      reasons.any? && reasons.join(". ")
    end

    private
      def run_validations!
        self.class.validators.each do |method|
          send(method)
        end
      end
  end
end
