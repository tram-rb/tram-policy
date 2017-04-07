class Tram::Policy::ValidationError < RuntimeError
  attr_reader :policy

  def initialize(policy)
    @policy = policy
  end
end
