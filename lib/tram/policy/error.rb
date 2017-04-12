require "i18n"
require 'core_ext/string'
require 'core_ext/hash'

module Tram
  class Policy
    class Error
      attr_reader :policy, :tags, :message

      def initialize(policy, message, tags)
        @policy = policy
        @tags = tags.symbolize_keys
        @initial_message = message
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
        if message.is_a?(Symbol)
          I18n.t(message, @tags.merge(scope: i18n_scope, default: "Error translation for missed text"))
        else
          message.to_s
        end
      end

      # Return an array of missed translations to every available locale
      #
      #   Tram::Policy::Error.new article_policy, :empty_title, field: 'title'
      #   error.missed_translations # => ['en.article.empty_title', 'ru.article.empty_title']
      def missed_translations
        return Array.new unless @initial_message.is_a?(Symbol)

        missed_locales = I18n.available_locales.select do |locale|
          !I18n.exists?("#{i18n_scope}.#{@initial_message}", locale)
        end
        missed_locales.map {|locale| "#{locale}.#{i18n_scope}.#{@initial_message}"}
      end

      # Get hash of tags and a message
      #
      #   error = Tram::Policy::Error.new(policy, "Title is empty", field: "title", level: "error")
      #   error.to_h # => {message: message, field: 'title', level: 'error'}
      def to_h
        tags.merge(message: message)
      end

      # Checks whether an error is equal to another object
      def ==(other)
        to_h == other.to_h
      end

      # Undefined methods treated as tags
      def method_missing(m, *args, &block)
        if tags.has_key?(m.to_sym)
          tags[m.to_sym]
        else
          super
        end
      end

      private
        def i18n_scope
          @policy.class.name.underscore
        end
    end
  end
end
