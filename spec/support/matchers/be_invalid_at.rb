RSpec::Matchers.define :be_invalid_at do |expected_tags|
  match do |policy|
    return false if policy.valid?

    policy.errors.any? do |error|
      error.tags.merge(expected_tags) == error.tags
    end
  end

  description do
    tags_string =
      expected_tags.map { |key, value| "#{key}: #{value}" }.join(" and ")

    "be invalid at #{tags_string}"
  end
end
