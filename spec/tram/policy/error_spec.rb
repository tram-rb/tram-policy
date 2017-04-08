RSpec.describe Tram::Policy::Error do
  subject do
    described_class.new("Some error message", { field: "name", level: "error" })
  end

  describe "#full_message" do
    it "should return message with tags" do
      expect(subject.full_message).to eq(
        "Some error message" => { field: "name", level: "error" },
      )
    end
  end

  describe "#to_h" do
    it "should return message, merged with tags" do
      expect(subject.to_h).to eq(
        message: "Some error message",
        field: "name",
        level: "error",
      )
    end
  end

  describe "#==" do
    context 'when two errors have equal messages and tags' do
      it "should return true" do
        another_error = build(
          :error,
          message: subject.message,
          tags: subject.tags
        )
        expect(subject == another_error).to be true
      end
    end

    context "when two errors have equal messages, but not equal tags" do
      it "should return false" do
        another_error = build(
          :error,
          message: subject.message,
          tags: { level: "absurd" }
        )
        expect(subject == another_error).to be false
      end
    end

    context "when two errors have equal tags, but not equal message" do
      it "should return false" do
        another_error = build(
          :error,
          message: "A different mesage",
          tags: subject.tags
        )
        expect(subject == another_error).to be false
      end
    end

    context "when two errors have different tags and message" do
      it "should return false" do
        another_error = build(
          :error,
          message: "A different mesage",
          tags: { level: "absurd" }
        )
        expect(subject == another_error).to be false
      end
    end
  end

  it "should have getter method for each tag" do
    expect(subject.level).to eq("error")
    expect(subject.field).to eq("name")

    expect { subject.some_other_tag }.to raise_error(NoMethodError)
  end
end
