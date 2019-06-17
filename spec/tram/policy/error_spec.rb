RSpec.describe Tram::Policy::Error do
  subject(:error) { described_class.new :bad, scope, options }

  let(:scope)   { %w[tram-policy] }
  let(:options) { { level: "warning", scope: scope } }

  describe "#item" do
    subject { error.item }
    it { is_expected.to eq [:bad, level: "warning", scope: scope] }
  end

  describe "#message" do
    subject { error.message }
    it { is_expected.to eq "Something bad has happened" }
  end

  describe "#==" do
    subject { error == other }

    context "when other object has the same #item:" do
      let(:other) { double to_a: error.item }
      it { is_expected.to eq true }
    end

    context "when other object has different #item:" do
      let(:other) { double to_a: [:foo] }
      it { is_expected.to eq false }
    end

    context "when other object not respond to #item:" do
      let(:other) { double }
      it { is_expected.to eq false }
    end
  end

  describe "arbitrary tag" do
    subject { error.send tag }

    context "when tag is defined:" do
      let(:tag) { "level" }
      it { is_expected.to eq "warning" }
    end

    context "when tag not defined:" do
      let(:tag) { :weight }
      it { is_expected.to be_nil }
    end
  end
end
