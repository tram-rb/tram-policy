FactoryGirl.define do
  factory :errors, class: Tram::Policy::Errors do
    initialize_with { new(Dummy::ReadinessPolicy) }
  end
end
