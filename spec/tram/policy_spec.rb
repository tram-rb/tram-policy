RSpec.describe Tram::Policy do
  before do
    I18n.available_locales = %w[en]
    I18n.backend.store_translations :en, yaml_fixture_file("en.yml")["en"]

    load_fixture "user_policy.rb"
    load_fixture "admin_policy.rb"
  end

  let(:policy) { Test::UserPolicy[user] }
  let(:user)   { double :user, name: name, email: nil, login: nil }
  let(:name)   { nil }

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

    context "when :stop_on_failure is set" do
      before { Test::UserPolicy.validate :name, stop_on_failure: true }

      it "stops validation after failure" do
        expect(user).to receive(:name).once
        expect(user).not_to receive(:email)

        Test::UserPolicy.new(user)
      end

      it "continues validation after success" do
        user = double :user, name: "Andy", email: nil, login: nil

        expect(user).to receive(:name).once.ordered
        expect(user).to receive(:email).once.ordered

        Test::UserPolicy.new(user)
      end
    end
  end

  describe "#inspect" do
    subject { policy.inspect }
    it { is_expected.to eq "#<Test::UserPolicy[{:user=>#<Double :user>}]>" }
  end

  describe "#errors" do
    subject { policy.errors }

    its(:class)  { is_expected.to eq Tram::Policy::Errors }
    its(:policy) { is_expected.to eql policy }
  end

  describe "#valid?" do
    context "when #errors are present" do
      subject { policy.valid? }
      let(:name) { nil }

      it { is_expected.to eq false }
    end

    context "with a filter" do
      subject { policy.valid? { |err| err.level != "error" } }
      let(:name) { nil }

      it "takes into account filtered errors" do
        expect(subject).to eq true
      end
    end

    context "when #errors are absent" do
      subject { policy.valid? }
      let(:name) { :foo }

      it { is_expected.to eq true }
    end
  end

  describe "#invalid?" do
    context "when #errors are present" do
      subject { policy.invalid? }
      let(:name) { nil }

      it { is_expected.to eq true }
    end

    context "with a filter" do
      subject { policy.invalid? { |err| err.level == "error" } }
      let(:name) { nil }

      it "filters errors out" do
        expect(subject).to eq false
      end
    end

    context "when #errors are absent" do
      subject { policy.invalid? }
      let(:name) { :foo }

      it { is_expected.to eq false }
    end
  end

  describe "#validate!" do
    context "when #errors are present" do
      subject { policy.validate! }
      let(:name) { nil }

      it "raises an exception" do
        expect { subject }.to raise_error Tram::Policy::ValidationError
      end
    end

    context "with a filter" do
      subject { policy.validate! { |err| err.level != "error" } }
      let(:name) { nil }

      it "takes into account filtered errors" do
        expect { subject }.not_to raise_error
      end
    end

    context "when #errors are absent" do
      subject { policy.validate! }
      let(:name) { :foo }

      it "doesn't raise an exception" do
        expect { subject }.not_to raise_error
      end
    end
  end

  describe "#t" do
    subject { policy.t(value, level: "error") }

    before do
      I18n.backend.store_translations :en, {
        "tram-policy" => {
          "test/user_policy" => {
            "name_presence" => "%{level}: Name is absent"
          }
        }
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
