require_relative "../dummy/awesome_title_policy.rb"
require_relative "../dummy/article.rb"

# Spec for inherited policy check
RSpec.describe Dummy::AwesomeTitlePolicy do
  let(:article) { build(:article, title: "Awesome title") }
  subject { described_class[article] }

  it { is_expected.to be_valid }

  describe "#invalid?" do
    before { article.text = nil }
    it "counts only errors, which yields true in block" do
      policy = described_class[article]
      invalid_without_block = policy.invalid?
      invalid_with_block =
        policy.invalid? { |error| error.level == :disaster }

      expect(invalid_without_block).to be true
      expect(invalid_with_block).to be false
    end
  end
end
