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

    # Adds error message to the collection
    #
    # @param [#to_s] message Either a message, or a symbolic key for translation
    # @param [Hash<Symbol, Object>] tags Tags to be attached to the message
    # @return [self] the collection
    #
    def add(message = nil, **tags)
      message ||= tags.delete(:message)
      raise ArgumentError.new("Error message should be defined") unless message

      @set << Tram::Policy::Error.new(@policy.t(message, tags), **tags)
      self
    end

    # Iterates by collected errors
    #
    # @yeldparam [Tram::Policy::Error]
    # @return [Enumerator<Tram::Policy::Error>]
    #
    def each
      @set.each { |error| yield(error) }
    end

    # Selects errors filtered by tags
    #
    # @param  [Hash<Symbol, Object>] filter
    # @return [Hash<Symbol, Object>]
    #
    def by_tags(**filter)
      filter = filter.to_a
      reject { |error| (filter - error.to_h.to_a).any? }
    end

    # Checks whether a collection is empty
    #
    # @return [Boolean]
    #
    def empty?(&block)
      block ? !any?(&block) : !any?
    end

    # The array of ordered error messages
    #
    # @return [Array<String>]
    #
    def messages
      @set.map(&:message).sort
    end

    # The array of ordered error messages with error tags info
    #
    # @return [Array<String>]
    #
    def full_messages
      @set.map(&:full_message).sort
    end

    # Merges other collection to the current one and returns new collection
    # with the current scope
    #
    # param [Tram::Policy::Errors] other Collection to be merged
    # yieldparam [Hash<Symbol, Object>]
    #
    # @example Add some tag to merged errors
    #   policy.merge(other) { |err| err[:source] = "other" }
    #
    def merge(other, **options)
      return self unless other.is_a?(self.class)

      other.each do |err|
        new_err = block_given? ? yield(err.to_h) : err.to_h
        add new_err.merge(options)
      end

      self
    end

    private

    def initialize(policy, errors = Set.new)
      @policy = policy
      @set    = errors
    end
  end
end
