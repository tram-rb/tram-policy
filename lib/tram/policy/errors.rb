require "tram/policy/error"

module Tram
  class Policy
    class Errors
      include Enumerable
      extend Forwardable

      def_delegators :@set, :each, :size, :empty?

      def initialize(policy)
        @policy = policy
        @set = []
      end

      # Adds an error to the collection
      # Return collection of errors
      #
      #   errors.add "Title is empty", field: "title", level: "error"
      def add(message, tags = {})
        @set.push Tram::Policy::Error.new(@policy, message, tags)
      end

      # Clear collection of errors
      # Return empty array
      def clear
        @set = []
      end

      # Return an array of messages
      def messages
        @set.map(&:message)
      end

      # Return an array of messages with tags info added
      def full_messages
        @set.map(&:full_message)
      end

      alias filter select
    end
  end
end
