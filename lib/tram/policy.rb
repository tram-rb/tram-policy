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
      # Policy constructor/validator (alias for [.new])
      #
      # @param  [Object] *args
      # @return [Tram::Policy]
      #
      def [](*args)
        new(*args)
      end
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
  end
end
