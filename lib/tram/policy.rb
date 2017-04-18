require "dry-initializer"
require "i18n"

module Tram
  class Policy
    require_relative "policy/errors"
    require_relative "policy/exceptions/validation_error"
    require_relative "policy/error"
    require_relative "policy/inflector"

    extend Dry::Initializer

    singleton_class.send(:alias_method, :[], :new)

    def initialize(*)
      super
      validation_methods = self.class.validation_methods
      validation_methods.each do |method|
        send(method)
      end
    end

    def errors
      Inflector.translate(self)
      @errors ||= Errors.new
    end

    def valid?(&block)
      (block ? @errors.reject(&block) : @errors).empty?
    end

    def invalid?(&block)
      (block ? @errors.select(&block) : @errors).any?
    end

    def validate!(&block)
      return nil if block_given? && valid?(&block)
      return unless @errors.any?
      raise Policy::ValidationError.new(self)
    end

    def messages
      @errors.messages
    end

    def full_messages
      @errors.full_messages
    end

    class << self
      def validate(*name)
        @validation_methods = validation_methods | name.map(&:to_sym)
      end

      def validation_methods
        @validation_methods ||= []
      end

      def inherited(subclass)
        super
        validation_methods.each do |m|
          subclass.validation_methods << m unless private_method_defined?(m)
        end
      end
    end
  end
end
