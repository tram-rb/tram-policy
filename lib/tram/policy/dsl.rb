class Tram::Policy
  # Class-level DSL for policy objects
  module DSL
    # @!method validate(name, opts)
    # Registers a validator
    #
    # @param  [#to_sym, nil] name (nil)
    # @option opts [Boolean] :stop_on_failure
    # @return [self]
    #
    def validate(name = nil, **opts, &block)
      local_validators << Validator.new(name, block, opts)
      self
    end

    # Policy constructor/validator (alias for [.new])
    #
    # @param  [Object] *args
    # @return [Tram::Policy]
    #
    def [](*args)
      new(*args)
    end

    # Sets the root scope of the policy and its subclasses
    #
    # @param  [String, Array<String>] value
    # @return [self]
    #
    def root_scope(*value)
      tap { @root_scope = value.flatten.map(&:to_s).reject(&:empty?) }
    end

    # Sets the scope leaf key of the policy (it won't be inherited by subclasses)
    #
    # @param  [String] value
    # @return [self]
    #
    def leaf_scope(value)
      tap { @leaf_scope = value&.to_s }
    end

    # Translation scope for a policy
    #
    # @return [Array<String>]
    #
    def scope
      @scope ||= Array(@root_scope) + [@leaf_scope || Inflector.underscore(name)]
    end

    # List of validators defined by a policy per se
    #
    # @return [Array<Proc>]
    #
    def local_validators
      @local_validators ||= []
    end

    # List of all applicable validators from both the policy and its parent
    #
    # @return [Array<Proc>]
    #
    def validators
      parent_validators = self == Tram::Policy ? [] : superclass.validators
      (parent_validators + local_validators).uniq
    end

    private

    def inherited(klass)
      super
      klass.send :instance_variable_set, :@root_scope, @root_scope
    end

    def self.extended(klass)
      super
      klass.send :instance_variable_set, :@root_scope, %w[tram-policy]
    end
  end
end
