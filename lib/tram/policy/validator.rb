class Tram::Policy
  # Describes a validator
  class Validator
    attr_reader :name, :stop_on_failure

    def ==(other)
      other.is_a?(self.class) && other.name == name
    end

    private

    def initialize(name, stop_on_failure: false)
      @name = name.to_sym
      @stop_on_failure = stop_on_failure
    end
  end
end
