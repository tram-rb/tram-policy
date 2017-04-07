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

    private
      def run_validations!
        self.class.validators.each do |method|
          send(method)
        end
      end
  end
end
