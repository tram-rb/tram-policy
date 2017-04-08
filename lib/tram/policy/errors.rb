module Tram
  class Policy
    class Errors
      include Enumerable

      def initialize(policy_class)
        @errors_list = []
        @policy_class = policy_class
      end

      def add(message, tags)
        unless message.is_a? Error::Message
          message = Error::Message.new(
            message,
            translation_scope: policy_i18n_scope,
            variables: tags
          )
        end

        error = Error.new(message, tags)
        @errors_list << error
      end

      def each(&block)
        @errors_list.each(&block)
      end

      private

      def policy_i18n_scope
        @policy_class.name.underscore.gsub("::", "/")
      end
    end
  end
end
