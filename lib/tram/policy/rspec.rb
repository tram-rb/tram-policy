require "rspec"

# Checks that a block provides policy that has errors under given tags
# It also check that selected messages has translations to all available locales
#
# @example
#   subject(:policy) { UserPolicy[name: nil] }
#   expect { policy }.to be_invalid_at field: "name", level: "error"
#
# You have to wrap expectation to a block called for available locales.
#
RSpec::Matchers.define :be_invalid_at do |**tags|
  supports_block_expectations

  # ****************************************************************************
  # Result collectors for all available locations
  # ****************************************************************************

  attr_accessor :policy

  def errors
    @errors ||= {}
  end

  def tags
    @tags ||= {}
  end

  def messages
    @messages ||= {}
  end

  # ****************************************************************************
  # Helpers to provide results for all locales
  # ****************************************************************************

  # Runs block in every available locale
  def in_available_locales
    locales = if respond_to?(:available_locales)
                available_locales
              else
                I18n.available_locales
              end

    locales.flat_map { |locale| I18n.with_locale(locale) { yield } }
  end

  def prepare_localized_results(policy_block, tags, locale)
    localized_policy = policy_block.call
    localized_errors = localized_policy&.errors || []
    self.policy      = localized_policy.inspect
    errors[locale]   = localized_errors.by_tags(tags)
    messages[locale] = localized_errors.full_messages
  end

  def prepare_results(policy_block, tags)
    original = I18n.locale
    I18n.available_locales.each do |locale|
      I18n.locale = locale
      prepare_localized_results(policy_block, tags, locale)
    end
  ensure
    I18n.locale = original
  end

  # ****************************************************************************
  # Checkers for collected results
  # ****************************************************************************

  # Checks if selected errors are present in all available locales
  def errored?
    errors.values.map(&:any?).reduce(true, &:&) == true
  end

  # Checks if selected errors are absent in all available locales
  def not_errored?
    errors.values.map(&:empty?).reduce(true, &:&) == true
  end

  # Checks if all collected errors are translated
  def translated?
    texts = errors.values.flatten.map(&:message)
    texts.select { |text| text.start_with?("translation missing") }.empty?
  end

  def report_errors
    text = "Actual errors:\n"
    messages.each do |locale, list|
      text << "  #{locale}:\n"
      list.each { |item| text << "  - #{item}\n" }
    end
    text
  end

  # ****************************************************************************
  # Positive matcher
  # ****************************************************************************

  match do |policy_block|
    prepare_results(policy_block, tags)
    errored? && translated?
  end

  failure_message do |_|
    text =  "The policy: #{policy}\n"
    text << "should have had errors with tags: #{tags}, "
    text << "whose messages are translated in all available locales.\n"
    text << report_errors
    text
  end

  # ****************************************************************************
  # Negative matcher
  # ****************************************************************************

  match_when_negated do |policy_block|
    prepare_results(policy_block, tags)
    not_errored?
  end

  failure_message_when_negated do |_|
    text =  "#{policy}\nshould not have had any error with tags: #{tags}.\n"
    text << report_errors
    text
  end
end

RSpec.shared_examples :invalid_policy do |condition = nil, **tags|
  constraint = "with tags: #{tags}" if tags.any?
  it ["is invalid", condition, constraint].compact.join(" ") do
    expect { subject }.to be_invalid_at(tags)
  end
end

RSpec.shared_examples :valid_policy do |condition = nil, **tags|
  constraint = "with tags: #{tags}" if tags.any?
  it ["is valid", condition, constraint].compact.join(" ") do
    expect { subject }.not_to be_invalid_at(tags)
  end
end
