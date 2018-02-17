class Tram::Policy
  # Enumerable collection of unique unordered validation errors
  #
  # Notice: A collection is context-dependent;
  #         it knows about a scope of policy it belongs to,
  #         and how to translate error messages in that scope.
  #
  class Errors
    include Enumerable

    # @!attribute [r] policy
    #
    # @return [Tram::Policy] the poplicy errors provided by
    #
    attr_reader :policy

    # @!method add(message, tags)
    # Adds error message to the collection
    #
    # @param [#to_s] message Either a message, or a symbolic key for translation
    # @param [Hash<Symbol, Object>] tags Tags to be attached to the message
    # @return [self] the collection
    #
    def add(message, **tags)
      tags = tags.merge(scope: policy.scope) unless tags.key?(:scope)
      raise ArgumentError.new("Error message should be defined") unless message
      tap { @set << Tram::Policy::Error.new(message, **tags) }
    end

    # Iterates by collected errors
    #
    # @yeldparam [Tram::Policy::Error]
    # @return [Enumerator<Tram::Policy::Error>]
    #
    def each
      @set.each { |error| yield(error) }
    end

    # @!method filter(key = nil, tags)
    # Filter errors by optional key and tags
    #
    # @param  [#to_s] key The key to filter errors by
    # @param  [Hash<Symbol, Object>] tags The list of tags to filter errors by
    # @return [Tram::Policy::Errors]
    #
    def filter(key = nil, **tags)
      list = each_with_object(Set.new) do |error, obj|
        obj << error if error.contain?(key, tags)
      end
      self.class.new(policy, list)
    end

    # @deprecated
    # @!method by_tags(tags)
    # Selects errors filtered by key and tags
    #
    # @param  [Hash<Symbol, Object>] tags List of options to filter by
    # @return [Array<Tram::Policy::Error>]
    #
    def by_tags(**tags)
      warn "[DEPRECATED] The method Tram::Policy::Errors#by_tags" \
           " will be removed in the v1.0.0. Use method #filter instead."

      filter(tags).to_a
    end

    # @!method empty?
    # Checks whether a collection is empty
    #
    # @return [Boolean]
    #
    def empty?(&block)
      block ? !any?(&block) : !any?
    end

    # The array of error items for translation
    #
    # @return [Array<Array>]
    #
    def items
      @set.map(&:item)
    end

    # The array of ordered error messages
    #
    # @return [Array<String>]
    #
    def messages
      @set.map(&:message).sort
    end

    # @deprecated
    # List of error descriptions
    #
    # @return [Array<String>]
    #
    def full_messages
      warn "[DEPRECATED] The method Tram::Policy::Errors#full_messages" \
           " will be removed in the v1.0.0."

      map(&:full_message)
    end

    # @!method merge(other, options)
    # Merges other collection to the current one and returns new collection
    # with the current scope
    #
    # @param [Tram::Policy::Errors] other   Collection to be merged
    # @param [Hash<Symbol, Object>] options Options to be added to merged errors
    # @yieldparam [Hash<Symbol, Object>] hash of error options
    # @return [self]
    #
    # @example Add some tag to merged errors
    #   policy.merge(other) { |err| err[:source] = "other" }
    #
    def merge(other, **options)
      return self unless other.is_a?(self.class)

      other.each do |err|
        key, opts = err.item
        opts = yield(opts) if block_given?
        add key, opts.merge(options)
      end

      self
    end

    private

    def initialize(policy, errors = [])
      @policy = policy
      @set    = Set.new(errors)
    end
  end
end
