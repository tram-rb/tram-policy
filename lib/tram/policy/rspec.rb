require "rspec"

RSpec::Matchers.define :be_invalid_at do |**tags|
  def locales
    @locales ||= I18n.available_locales
  end

  def check(policy, tags)
    @errors ||= policy.errors.filter(tags).map do |error|
      { item: error.item }.tap do |obj|
        locales.each { |l| obj[l] = I18n.with_locale(l) { error.message } }
      end
    end
  end

  attr_reader :errors

  def missed_translations
    @missed_translations ||= \
      errors.flat_map { |rec| rec.values_at(*locales) }
            .select { |message| message.start_with? "translation missing" }
  end

  def report_errors
    locales.each_with_object("Actual errors:\n") do |loc, text|
      text << "  #{loc}:\n"
      errors.each { |err| text << "  - #{err[loc]} #{err[:item]}\n" }
    end
  end

  match do |policy|
    check(policy, tags)
    errors.any? && missed_translations.empty?
  end

  match_when_negated do |policy|
    check(policy, tags)
    errors.empty?
  end

  failure_message do |policy|
    desc = tags.any? ? " with tags: #{tags}" : ""
    text =  "The policy: #{policy}\n"
    text << " should have had errors#{desc},"
    text << " whose messages are translated in all available locales.\n"
    text << report_errors
    text
  end

  failure_message_when_negated do |policy|
    desc = tags.any? ? " with tags: #{tags}" : ""
    text =  "#{policy}\nshould not have had any error#{desc}.\n"
    text << report_errors
    text
  end
end

RSpec::Matchers.define :be_invalid do
  match do |policy|
    return expect(policy.valid?).to(be_falsey) unless policy.is_a?(Tram::Policy)
    expect(policy).to be_invalid_at
  end

  match_when_negated do |policy|
    return expect(policy.valid?).to(be_truthy) unless policy.is_a?(Tram::Policy)
    expect(policy).not_to be_invalid_at
  end
end

RSpec::Matchers.define :be_valid_at do |**tags|
  match do |policy|
    expect(policy).not_to be_invalid_at(tags)
  end

  match_when_negated do |policy|
    expect(policy).to be_invalid_at(tags)
  end
end
