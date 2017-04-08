module Tram
  class Policy
    class Errors
      include Enumerable

      def initialize(policy_class)
        @errors_list = []
        @policy_class = policy_class
      end

      def add(message, tags)
        message = translate_message(message, tags) if message.is_a? Symbol

        error = Error.new(message, tags)
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

      private

      def translate_message(message, tags)
        I18n.t(
          @policy_class.name.underscore.gsub("::", "/") + "." + message.to_s,
          tags
        )
      end
    end
  end
end
