class Tram::Policy
  # Validation error with message and assigned tags
  #
  # Notice: an error is context-independent; it knows nothing about
  #         a collection it is placed to; it can be safely moved
  #         from one collection of [Tram::Policy::Errors] to another.
  #
  class Error
    # @!method self.new(value, opts = {})
    # Builds an error
    #
    # If another error is send to the constructor, the error returned unchanged
    #
    # @param  [Tram::Policy::Error, #to_s] value
    # @param  [Hash<Symbol, Object>] tags
    # @return [Tram::Policy::Error]
    #
    def self.new(value, **tags)
      value.instance_of?(self) ? value : super
    end

    # @!attribute [r] key
    # @return [Symbol, String] error key
    attr_reader :key

    # @!attribute [r] tags
    # @return [Hash<Symbol, Object>] error tags
    attr_reader :tags

    # List of arguments for [I18n.t]
    #
    # @return [Array]
    #
    def item
      [key, tags]
    end
    alias to_a item

    # Text of error message translated to the current locale
    #
    # @return [String]
    #
    def message
      key.is_a?(Symbol) ? I18n.t(*item) : key.to_s
    end

    # Fetches an option
    #
    # @param [#to_sym] tag
    # @return [Object]
    #
    def [](tag)
      tags[tag.to_sym]
    end

    # Fetches the tag
    #
    # @param [#to_sym] tag
    # @param [Object] default
    # @param [Proc] block
    # @return [Object]
    #
    def fetch(tag, default = UNDEFINED, &block)
      if default == UNDEFINED
        tags.fetch(tag.to_sym, &block)
      else
        tags.fetch(tag.to_sym, default, &block)
      end
    end

    # Compares an error to another object using method [#item]
    #
    # @param  [Object] other Other object to compare to
    # @return [Boolean]
    #
    def ==(other)
      other.respond_to?(:to_a) && other.to_a == item
    end

    # @!method contain?(some_key = nil, some_tags = {})
    # Checks whether the error contain given key and tags
    #
    # @param [Object] some_key Expected key of the error
    # @param [Hash<Symbol, Object>] some_tags Expected tags of the error
    # @return [Boolean]
    #
    def contain?(some_key = nil, **some_tags)
      return false if some_key&.!= key
      some_tags.each { |k, v| return false unless tags[k] == v }
      true
    end

    private

    UNDEFINED = Dry::Initializer::UNDEFINED
    DEFAULT_SCOPE = %w[tram-policy errors].freeze

    def initialize(key, **tags)
      @key  = key
      @tags = tags
      @tags[:scope] = @tags.fetch(:scope) { DEFAULT_SCOPE } if key.is_a?(Symbol)
    end

    def respond_to_missing?(*)
      true
    end

    def method_missing(name, *args, **kwargs, &block)
      args.any? || block ? super : tags[name]
    end
  end
end
