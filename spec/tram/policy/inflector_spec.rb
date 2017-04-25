RSpec.describe Tram::Policy::Inflector do
  let(:snake) { "test/admin2_user_new_policy" }
  let(:camel) { "Test::Admin2UserNewPolicy" }

  describe "#underscore" do
    subject { described_class.underscore "Test::Admin2USERNew-Policy" }
    it { is_expected.to eq snake }
  end

  describe "#camelize" do
    subject { described_class.camelize snake }
    it { is_expected.to eq camel }
  end
end
