require "tram/policy/error"

module Tram
  class Policy
    class Errors
      extend Forwardable

      def_delegators :@errors, :size, :empty?

      def initialize(policy)
        @policy = policy
        @errors = []
      end

      # Adds an error to the collection
      # Return collection of errors
      #
      #   errors.add "Title is empty", field: "title", level: "error"
      def add(message, tags = {})
        @errors.push Tram::Policy::Error.new(@policy, message, tags)
      end

      # Clear collection of errors
      # Return empty array
      def clear
        @errors = []
      end
    end
  end
end
