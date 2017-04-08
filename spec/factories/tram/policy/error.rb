FactoryGirl.define do
  factory :error, class: Tram::Policy::Error do
    message "Some error message"
    tags { {} }

    initialize_with { new(message, tags) }
  end
end
