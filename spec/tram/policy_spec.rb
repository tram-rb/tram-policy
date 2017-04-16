RSpec.describe Tram::Policy do
  before do
    class Test::UserPolicy < Tram::Policy
      param :user
    end
  end

  let(:policy) { Test::UserPolicy[user] }
  let(:user)   { double :user }

  describe "Dry::Initializer interface" do
    it "is accessible" do
      expect(described_class.ancestors).to include Dry::Initializer
    end
  end

  describe "#inspect" do
    subject { policy.inspect }
    it { is_expected.to eq "#<Test::UserPolicy[{:user=>#<Double :user>}]>" }
  end
end
