require "dry-initializer"
require "tram/policy/errors"
require "tram/policy/validation_error"

module Tram
  class Policy
    extend Dry::Initializer

    @validators = []

    class << self
      alias [] new
      attr_reader :validators

      def inherit_validators(validators)
        @validators ||= []
        @validators.concat(validators)
      end

      def inherited(sublass)
        sublass.inherit_validators(@validators)
        super
      end

      private

      def validate(method_name)
        @validators << method_name
      end
    end

    def errors
      @errors ||= Errors.new(self.class)
    end

    def initialize(*args)
      super

      self.class.validators.each do |validator|
        send(validator)
      end
    end

    def valid?(&block)
      !errors.any?(&block)
    end

    def invalid?(&block)
      !valid?(&block)
    end

    def messages
      errors.map(&:message)
    end

    def full_messages
      errors.map(&:full_message)
    end

    def validate!(&block)
      return if valid?(&block)

      raise ValidationError.new(messages.join("; "), self)
    end
  end
end
