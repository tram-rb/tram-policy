class Tram::Policy
  # Validation error with message and assigned tags
  #
  # Notice: an error is context-independent; it knows nothing about
  #         a collection it is placed to; it can be safely moved
  #         from one collection of [Tram::Policy::Errors] to another.
  #
  class Error
    # Builds an error
    #
    # If another error is send to the constructor, the error returned unchanged
    #
    # @param  [Tram::Policy::Error, #to_s] value
    # @param  [Hash<Symbol, Object>] opts
    # @return [Tram::Policy::Error]
    #
    def self.new(value, **opts)
      return value if value.is_a? self
      super
    end

    # @!attribute [r] message
    #
    # @return [String] The error message text
    #
    attr_reader :message

    # The full message (message and tags info)
    #
    # @return [String]
    #
    def full_message
      [message, @tags].reject(&:empty?).join(" ")
    end

    # Converts the error to a simple hash with message and tags
    #
    # @return [Hash<Symbol, Object>]
    #
    def to_h
      @tags.merge(message: message)
    end

    # Fetches either message or a tag
    #
    # @param [#to_sym] tag
    # @return [Object]
    #
    def [](tag)
      to_h[tag.to_sym]
    end

    # Fetches either message or a tag
    #
    # @param [#to_sym] tag
    # @param [Object] default
    # @param [Proc] block
    # @return [Object]
    #
    def fetch(tag, default, &block)
      to_h.fetch(tag.to_sym, default, &block)
    end

    # Compares an error to another object using method [#to_h]
    #
    # @param  [Object] other Other object to compare to
    # @return [Boolean]
    #
    def ==(other)
      other.respond_to?(:to_h) && other.to_h == to_h
    end

    private

    def initialize(message, **tags)
      @message = message.to_s
      @tags = tags
    end

    def respond_to_missing?(*)
      true
    end

    def method_missing(name, *args, &block)
      args.any? || block ? super : @tags[name]
    end
  end
end
