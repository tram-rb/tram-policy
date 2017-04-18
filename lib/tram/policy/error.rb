module Tram
  class Policy::Error
    attr_reader :message, :tags

    def initialize(message, tags = {})
      @tags = tags
      @message = generate_message(message)
    end

    def to_h
      { message: message }.merge(tags)
    end

    def generate_message(message)
      Policy::Inflector.generate(message, tags)
    end

    def full_message
      (tags.any? ? [message] << tags : [message]).join(": ")
    end

    def eql?(other)
      return unless @tags.any?
      @tags == other.tags &&
      @message == other.message
    end

    def hash
      @tags.hash + @message.hash
    end

    def ==(other)
      eql?(other)
    end

    # rubocop: disable Style/MethodMissing
    def method_missing(name)
      # robocop When using method_missing, fall back on super
      # we desidet return nil but i'm not sure
      tags[name]
    end

    def respond_to_missing?
      true
    end
  end
end
