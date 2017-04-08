require_relative "../dummy/readiness_policy.rb"
require_relative "../dummy/article.rb"

RSpec.describe Dummy::ReadinessPolicy do
  let(:article) { build(:article) }
  subject { described_class[article] }

  it { is_expected.to be_valid }

  describe "#errors" do
    before { article.title = nil }

    it "should return the Enumerable" do
      expect(subject.errors).to be_kind_of Enumerable
      expect(subject.errors).to respond_to :each
    end
  end

  describe "#messages" do
    before { article.title = nil }

    it "should return array of errors messages" do
      expect(subject.messages).to match_array(["Title is empty"])
    end
  end

  describe "I18n" do
    before { article.text = nil }
    it "should translate message symbol" do
      expect(subject.messages).to \
        match_array(["Validation error: text is empty"])
    end
  end

  describe "#full_messages" do
    before { article.title = nil }

    it "should return array of errors messages with additional info" do
      expect(subject.full_messages).to eq([
        { "Title is empty" => { field: 'title', level: 'error' } }
      ])
    end
  end

  describe "#valid" do
    context 'with block' do
      before { article.text = nil }
      it "ignores errors, which yields true in block" do
        valid_without_block = subject.valid?
        valid_with_block = subject.valid? { |error| error.level == :warning }

        expect(valid_without_block).to be false
        expect(valid_with_block).to be true
      end
    end
  end

  describe "#invalid" do
    context 'with block' do
      before { article.text = nil }
      it "counts only errors, which yields true in block" do
        invalid_without_block = subject.invalid?
        invalid_with_block =
          subject.invalid? { |error| error.level == :disaster }

        expect(invalid_without_block).to be true
        expect(invalid_with_block).to be false
      end
    end
  end

  describe "#validate!" do
    before do
      article.title = nil
      article.subtitle = nil
    end

    context 'without block' do
      it 'should raise error' do
        expect { subject.validate! }.to \
          raise_error(Tram::Policy::ValidationError, /Title is empty/)
      end
    end

    context 'with block' do
      it "should count only errors, that yield true in block" do
        expect {
          subject.validate! { |error| error.level == 'disaster' }
        }.not_to raise_error
      end
    end

    it "should raise exception, which contains policy object itself" do
      begin
        subject.validate!
      rescue Tram::Policy::ValidationError => error
        expect(error.policy).to eq(subject)
      end
    end

    it "should raise exception, which message is built from errors" do
      expect {
        subject.validate!
      }.to raise_error(
        Tram::Policy::ValidationError,
        "Title is empty; Subtitle is empty"
      )
    end
  end

  context "with wrong title" do
    before { article.title = nil }
    it { is_expected.to be_invalid_at field: "title" }
  end

  context "with wrong text" do
    before { article.text = nil }
    it { is_expected.to be_invalid_at field: "text", level: "error" }
  end
end
