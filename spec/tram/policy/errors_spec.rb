RSpec.describe Tram::Policy::Errors do
  let(:scope)  { %w[tram-policy] }
  let(:errors) { described_class.new(scope: scope) }

  describe ".new" do
    subject { errors }

    it { is_expected.to be_kind_of Enumerable }
    it { is_expected.to respond_to :empty? }
    it { is_expected.to be_empty }
    its(:scope) { is_expected.to eql scope }
  end

  describe "#add" do
    subject { errors.add :omg, level: "info", field: "name" }

    let(:error) { errors.to_a.last }

    it "adds an error to the collection:" do
      expect { 2.times { subject } }.to change { errors.count }.by 1

      expect(error).to be_kind_of Tram::Policy::Error
      expect(error)
        .to eq [:omg, level: "info", field: "name", scope: scope]
    end
  end

  describe "#empty?" do
    subject { errors.add :omg, level: "info", field: "name" }

    it "checks whether error present" do
      expect(subject).not_to be_empty
    end

    it "accepts a block" do
      expect(subject.empty? { |error| error.level != "info" }).to eq true
    end
  end

  describe "#items" do
    subject { errors.items }

    before { errors.add "OMG!", level: "info", field: "name" }
    it { is_expected.to eq errors.map(&:item) }
  end

  describe "#merge" do
    let(:other) { described_class.new(scope: scope) }

    before do
      errors.add "D'OH!", level: "disaster"
      other.add  "OUCH!", level: "error"
    end

    context "without a block:" do
      subject { errors.merge(other) }

      it "merges other collection as is" do
        expect(subject).to be_a Tram::Policy::Errors
        expect(subject.items).to match_array [
          ["D'OH!", level: "disaster", scope: scope],
          ["OUCH!", level: "error",    scope: scope]
        ]
      end
    end

    context "with a block:" do
      subject { errors.merge(other) { |err| err.merge(source: "Homer") } }

      it "merges filtered collection as is" do
        expect(subject).to be_a Tram::Policy::Errors
        expect(subject.items).to match_array [
          ["D'OH!", level: "disaster", scope: scope],
          ["OUCH!", level: "error",    scope: scope, source: "Homer"]
        ]
      end
    end

    context "with options:" do
      subject { errors.merge(other, source: "Homer") }

      it "merges other collection with given options" do
        expect(subject).to be_a Tram::Policy::Errors
        expect(subject.items).to match_array [
          ["D'OH!", level: "disaster", scope: scope],
          ["OUCH!", level: "error",    scope: scope, source: "Homer"]
        ]
      end
    end

    context "with block and options:" do
      subject { errors.merge(other, id: 5) { |err| err.merge id: 3, age: 4 } }

      it "merges filtered collection with given options" do
        expect(subject).to be_a Tram::Policy::Errors
        expect(subject.items).to match_array [
          ["D'OH!", level: "disaster", scope: scope],
          ["OUCH!", level: "error",    scope: scope, id: 5, age: 4]
        ]
      end
    end

    context "with no errors:" do
      subject { errors.merge 1 }
      it { is_expected.to eql errors }
    end
  end

  describe "#messages" do
    subject { errors.messages }

    before { errors.add "OMG!", level: "info", field: "name" }
    it { is_expected.to eq errors.map(&:message) }
  end

  describe "#filter" do
    before do
      errors.add :foo, field: "name",  level: "error"
      errors.add :foo, field: "email", level: "info"
      errors.add :foo, field: "email", level: "error"
    end

    context "with filter" do
      subject { errors.filter level: "error" }

      it "returns selected errors only" do
        expect(subject).to match_array [
          [:foo, field: "name",  level: "error", scope: scope],
          [:foo, field: "email", level: "error", scope: scope]
        ]
      end
    end

    context "without a filter" do
      subject { errors.filter }

      it "returns selected all errors" do
        expect(subject).to match_array errors.to_a
      end
    end
  end
end
