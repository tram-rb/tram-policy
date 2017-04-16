require "dry-initializer"
require "i18n"

module Tram
  # Base class for policy objects with composable validation errors
  class Policy
    require_relative "policy/validation_error"
    require_relative "policy/inflector"
    require_relative "policy/error"
    require_relative "policy/errors"

    extend Dry::Initializer

    class << self
      # Registers a validator
      #
      # @param  [#to_sym, Array<#to_sym>] names
      # @return [self]
      #
      def validate(*names)
        @validators = validators | names.flatten.map(&:to_sym)
        self
      end

      # Policy constructor/validator (alias for [.new])
      #
      # @param  [Object] *args
      # @return [Tram::Policy]
      #
      def [](*args)
        new(*args)
      end

      private

      def validators
        @validators ||= []
      end

      def inherited(klass)
        super
        klass.validate validators
      end
    end

    # Translates a message in the scope of current policy
    #
    # @param  [#to_s] message
    # @param  [Hash<Symbol, Object>] options
    # @return [String]
    #
    def t(message, **options)
      return message.to_s unless message.is_a? Symbol
      I18n.t message, options.merge(scope: @__scope__)
    end

    # Human-readable representation of the policy
    #
    # @example Displays policy name and its attributes
    #   UserPolicy[name: "Andy"].inspect
    #   # => #<UserPolicy["name" => "Andy"]>
    #
    # @return [String]
    #
    def inspect
      "#<#{self.class.name}[#{@__options__}]>"
    end

    private

    def initialize(*)
      super
      @__scope__ = Inflector.underscore(self.class.name)
      self.class.send(:validators).each { |name| send(name) }
    end
  end
end
