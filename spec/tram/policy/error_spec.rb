require "spec_helper"

RSpec.describe Tram::Policy::Error do
  before do
    class NameSpace; end
    Tram::Policy::Inflector.translate(NameSpace.new)
  end

  let(:tram_policy_error) do
    Tram::Policy::Error.new(
      :test_locale,
      field: "title",
      level: "error"
    )
  end

  let(:diff_tram_policy_error) do
    Tram::Policy::Error.new(
      "Diff error",
      field: "title",
      level: "error"
    )
  end

  context "Support following methods" do
    it { expect(tram_policy_error).to respond_to(:tags) }
    it { expect(tram_policy_error).to respond_to(:message) }
    it { expect(tram_policy_error).to respond_to(:full_message) }
    it { expect(tram_policy_error).to respond_to(:to_h) }
    it { expect(tram_policy_error).to respond_to(:==) }
  end

  it "#tags" do
    expect(tram_policy_error.tags).to include :field, :level
  end

  it "#message" do
    expect(tram_policy_error.message).to eq("Test validation")
  end

  it "#full_message" do
    expect(tram_policy_error.full_message).to eq \
      "Test validation: {:field=>\"title\", :level=>\"error\"}"
  end

  it "#to_h" do
    expect(tram_policy_error.to_h).to include :message, :field, :level
  end

  it "#==" do
    expect(tram_policy_error == tram_policy_error).to be true
    expect(tram_policy_error == diff_tram_policy_error).to be false
  end

  context "undefined methods tags" do
    it { expect(tram_policy_error.field).to eq("title") }
    it { expect(tram_policy_error.level).to eq("error") }
    it { expect(tram_policy_error.time).to be nil }
  end

  context "when tronslation messing" do
    let(:translation) { Tram::Policy::Error.new(:missing) }

    it "#message return translation message" do
      expect(translation.message).to eq \
        "translation missing: en.name_space.missing"
    end
  end
end
