class Tram::Policy
  # @private
  class Validator
    attr_reader :scope, :name, :block, :stop_on_failure

    def ==(other)
      other.is_a?(self.class) && name && other.name == name
    end

    def check(object)
      object.__send__ :instance_variable_set, :@__scope__, scope
      name ? object.__send__(name) : object.instance_exec(&block)
    end

    private

    def initialize(scope, name, block, stop_on_failure: false)
      @scope = scope
      @name  = name&.to_sym
      @block = block
      raise "Provide either method name or a block" unless !name ^ !block
      @stop_on_failure = stop_on_failure
    end
  end
end
