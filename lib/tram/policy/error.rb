require "i18n"

module Tram
  class Policy
    class Error
      attr_reader :tags, :message

      def initialize(policy, message, tags)
        @policy, @tags = policy, tags
        @message = generate_message(message)
      end

      # Return the message with tags info added
      #
      #   error = Tram::Policy::Error.new(policy, "Title is empty", field: "title", level: "error")
      #   error.full_message # => "Title is empty: {:field=>\"title\", :level=>\"error\"}"
      def full_message
        "#{@message}: #{@tags}"
      end

      # Translates an error message in its default scope
      #
      # Say you have class Article::ReadinessPolicy < Tram::Policy; end
      # and you wanted the translation for the :blank error message for
      # the title attribute, it looks for this translation: article/readiness_policy.empty
      def generate_message(message)
        if message.is_a?(String)
          message
        elsif message.is_a?(Symbol)
          p @policy.class.to_s
          I18n.t(message, @tags.merge(scope: underscore(@policy.class.name), default: "Error translation for missed text"))
        else
          raise ArgumentError.new("Only strings or symbols are allowed")
        end
      end

      private
        def underscore(camel_cased_word)
          camel_cased_word.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
        end
    end
  end
end
