module Tram
  class Policy
    class Error
      attr_reader :tags

      def initialize(message, **tags)
        @message = message
        @tags = tags
      end

      def message
        @message.to_s
      end

      def raw_message
        @message.content
      end

      def full_message
        { message => tags }
      end

      def to_h
        tags.merge(message: message)
      end

      def ==(other)
        return false unless other.kind_of? self.class

        messages_are_equal = message == other.message
        tags_are_equal = tags == other.tags

        messages_are_equal && tags_are_equal
      end

      def respond_to_missing?(method_name)
        tags_include? method_name
      end

      def method_missing(method_name)
        return tags[method_name] if tags_include? method_name
        super
      end

      private

      def tags_include?(tag)
        tags.keys.include? tag
      end
    end
  end
end
