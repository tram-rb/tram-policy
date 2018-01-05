class Tram::Policy
  # @private
  class Validator
    attr_reader :name, :block, :stop_on_failure

    def ==(other)
      other.is_a?(self.class) && name && other.name == name
    end

    def check(object)
      name ? object.__send__(name) : object.instance_exec(&block)
    end

    private

    def initialize(name, block, stop_on_failure: false)
      @name  = name&.to_sym
      @block = to_lambda(block)
      raise "Provide either method name or a block" unless !name ^ !block
      @stop_on_failure = stop_on_failure
    end

    def to_lambda(block)
      return unless block

      unbound = Module.new.module_exec do
        instance_method define_method(:_, &block)
      end

      ->(&b) { unbound.bind(self == block ? block.receiver : self).call(&b) }
    end
  end
end
