RSpec.describe Tram::Policy::Errors do
  let(:policy) { double :policy, t: "OMG!" }
  let(:errors) { described_class.new(policy) }

  describe ".new" do
    subject { errors }

    it { is_expected.to be_kind_of Enumerable }
    it { is_expected.to respond_to :empty? }
    it { is_expected.to be_empty }
    its(:policy) { is_expected.to eql policy }
  end

  describe "#add" do
    subject     { errors.add :omg, level: "info", field: "name" }
    let(:error) { errors.to_a.last }

    it "adds an error to the collection:" do
      expect { 2.times { subject } }.to change { errors.count }.by 1

      expect(error).to be_kind_of Tram::Policy::Error
      expect(error).to eq message: "OMG!", level: "info", field: "name"
    end
  end

  describe "#merge" do
    let(:other) { described_class.new(policy) }

    before do
      errors.add "D'OH!", level: "disaster"
      other.add  "OUCH!", level: "error"
    end

    context "without a block:" do
      subject { errors.merge(other) }

      it "merges other collection as is" do
        expect(subject).to be_a Tram::Policy::Errors
        expect(subject.map(&:to_h)).to match_array [
          { message: "OMG!", level: "disaster" },
          { message: "OMG!", level: "error" }
        ]
      end
    end

    context "with a block:" do
      subject { errors.merge(other) { |err| err.merge(source: "Homer") } }

      it "merges filtered collection as is" do
        expect(subject).to be_a Tram::Policy::Errors
        expect(subject.map(&:to_h)).to match_array [
          { message: "OMG!", level: "disaster" },
          { message: "OMG!", level: "error", source: "Homer" }
        ]
      end
    end

    context "not errors:" do
      subject { errors.merge 1 }
      it { is_expected.to eql errors }
    end
  end

  describe "#messages" do
    subject { errors.messages }

    it { is_expected.to eq [] }

    context "with errors added:" do
      before  { errors.add "OMG!", level: "info", field: "name" }
      it { is_expected.to eq %w[OMG!] }
    end
  end

  describe "#full_messages" do
    subject { errors.full_messages }

    it { is_expected.to eq [] }

    context "with errors added:" do
      before  { errors.add "OMG!", level: "info", field: "name" }
      it { is_expected.to eq ["OMG! {:level=>\"info\", :field=>\"name\"}"] }
    end
  end

  describe "#by_tags" do
    before do
      errors.add :foo, field: "name",  level: "error"
      errors.add :foo, field: "email", level: "info"
      errors.add :foo, field: "email", level: "error"
    end

    context "with filter" do
      subject { errors.by_tags level: "error" }

      it "returns selected errors only" do
        expect(subject.map(&:to_h)).to match_array [
          { message: "OMG!", field: "name",  level: "error" },
          { message: "OMG!", field: "email", level: "error" }
        ]
      end
    end

    context "without a filter" do
      subject { errors.by_tags }

      it "returns selected all errors" do
        expect(subject.map(&:to_h)).to match_array errors.to_a
      end
    end
  end
end
