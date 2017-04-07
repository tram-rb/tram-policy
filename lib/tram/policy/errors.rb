require "tram/policy/error"

module Tram
  class Policy
    class Errors
      include Enumerable
      extend Forwardable

      def_delegators :@errors, :each, :size, :empty?
      attr_reader :errors

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

      # Return an array of messages
      def messages
        @errors.map(&:message)
      end

      # Return an array of messages with tags info added
      def full_messages
        @errors.map(&:full_message)
      end
    end
  end
end
