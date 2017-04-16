RSpec.describe Tram::Policy::Error do
  subject(:error) { described_class.new "Something bad happened", tags }

  let(:tags) { { level: "warning" } }

  describe "#message" do
    subject { error.message }
    it { is_expected.to eq "Something bad happened" }
  end

  describe "#full_message" do
    subject { error.full_message }

    context "with tags:" do
      it { is_expected.to eq "Something bad happened {:level=>\"warning\"}" }
    end

    context "without tags:" do
      let(:tags) { {} }
      it { is_expected.to eq "Something bad happened" }
    end
  end

  describe "#to_h" do
    subject { error.to_h }
    it { is_expected.to eq message: "Something bad happened", level: "warning" }
  end

  describe "#==" do
    subject { error == other }

    context "when other object has the same #to_h:" do
      let(:other) { double to_h: error.to_h }
      it { is_expected.to eq true }
    end

    context "when other object has different #to_h:" do
      let(:other) { double to_h: error.to_h.merge(foo: :bar) }
      it { is_expected.to eq false }
    end

    context "when other object not respond to #to_h:" do
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
