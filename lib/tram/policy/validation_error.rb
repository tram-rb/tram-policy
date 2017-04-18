class Tram::Policy::ValidationError < RuntimeError
  attr_reader :policy

  def initialize(policy, errors)
    @policy = policy
    super(errors.map(&:full_message).join('. '))
  end
end
