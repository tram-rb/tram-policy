RSpec.describe Tram::Policy do
  before do
    I18n.available_locales = %w(en)

    class Test::UserPolicy < Tram::Policy
      param :user

      validate :name, "email", %w(email name)

      private

      def name
        user.name
      end

      def email
        user.email
      end

      def login
        user.login
      end
    end

    class Test::AdminPolicy < Test::UserPolicy
      validate :login
      validate :name
    end
  end

  let(:policy) { Test::UserPolicy[user] }
  let(:user)   { double :user, name: nil, email: nil, login: nil }

  describe "Dry::Initializer interface" do
    it "is accessible" do
      expect(described_class.ancestors).to include Dry::Initializer
    end
  end

  describe ".validate" do
    it "defines validators to be called by initializer in proper order" do
      expect(user).to receive(:name).once.ordered
      expect(user).to receive(:email).once.ordered

      Test::UserPolicy.new(user)
    end

    it "preserves order of parent class validators" do
      expect(user).to receive(:name).once.ordered
      expect(user).to receive(:email).once.ordered
      expect(user).to receive(:login).once.ordered

      Test::AdminPolicy.new(user)
    end
  end

  describe "#inspect" do
    subject { policy.inspect }
    it { is_expected.to eq "#<Test::UserPolicy[{:user=>#<Double :user>}]>" }
  end

  describe "#t" do
    subject { policy.t(value, level: "error") }

    before do
      I18n.backend.store_translations :en, {
        "test/user_policy" => { "name_presence" => "%{level}: Name is absent" }
      }
    end

    context "string" do
      let(:value) { "Name should be present" }
      it { is_expected.to eq value }
    end

    context "non-symbol" do
      let(:value) { 42 }
      it { is_expected.to eq "42" }
    end

    context "symbol" do
      let(:value) { :name_presence }
      it { is_expected.to eq "error: Name is absent" }
    end
  end
end
