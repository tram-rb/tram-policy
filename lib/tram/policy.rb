require "dry-initializer"
require "i18n"

module Tram
  class Policy
    extend Dry::Initializer

    class << self
      alias [] new
      attr_reader :validators
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

    private

    def self.validate(method_name)
      @validators ||= []
      @validators << method_name
    end
  end
end
