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
        init_validators
        @validators.push(method)
      end

      def init_validators
        @validators ||= Array.new
      end

      attr_reader :validators
    end

    def initialize(*args, options)
      super
      self.class.init_validators
      @errors = Tram::Policy::Errors.new(self)
      run_validations!
    end

    # Return true if no errors exist
    def valid?(&block)
      errors.clear
      run_validations!

      filtered_errors = block ? @errors.reject(&block) : @errors
      filtered_errors.empty?
    end

    # Return true if some error exists
    def invalid?(&block)
      errors.clear
      run_validations!

      filtered_errors = block ? @errors.select(&block) : @errors
      filtered_errors.any?
    end

    # Raises Tram::Policy::ValidationError exception if some error exists
    # Its message is built from selected errors (taking into account a validation! filter)
    def validate!(&block)
      filtered_errors = block ? @errors.reject(&block) : @errors
      raise Tram::Policy::ValidationError.new(self, filtered_errors) unless valid?(&block)
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
