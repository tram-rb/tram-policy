RSpec.describe Tram::Policy::Error::Message do
  subject { described_class.new("Some message") }

  describe "#to_s" do
    context "with symbolic content" do
      let(:message) do
        described_class.new(
          :empty_text,
          translation_scope: "dummy/readiness_policy",
          variables: { field: "text", level: "error" }
        )
      end

      it "should return translated message" do
        expect(message.to_s).to eq("Validation error: text is empty")
      end
    end

    context "with string content" do
      let(:message) { described_class.new("Some error") }

      it "should return original message" do
        expect(message.to_s).to eq("Some error")
      end
    end
  end
end
