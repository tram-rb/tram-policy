module Tram
  class Policy
    class Errors
      include Enumerable

      def initialize
        @errors_list = []
      end

      def add(message, options)
        error = Error.new(message, options)
        @errors_list << error
      end

      def each(&block)
        @errors_list.each(&block)
      end

      def messages
        @errors_list.map(&:message)
      end

      def full_messages
        @errors_list.map(&:full_messages)
      end
    end
  end
end
