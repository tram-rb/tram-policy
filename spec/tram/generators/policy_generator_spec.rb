require "generators/tram/policy/policy_generator"

RSpec.describe Tram::Policy::Generators::PolicyGenerator do
  def destination
    File.expand_path("../../../../tmp", __FILE__)
  end

  def config
    { destination_root: destination, behavior: :force }
  end

  def file(path)
    File.expand_path(path, destination)
  end

  context "with attributes" do
    before(:all) do
      args = %w[user/readiness_policy user user:name user:email]
      described_class.start(args, config)
    end

    # I couldn't figure out, how to make Thor rewrite files
    # so for now clean them manually
    after(:all) do
      FileUtils.rm_rf(destination)
    end

    describe "Policy class" do
      subject { file("app/policies/user/readiness_policy.rb") }

      it { is_expected.to exist }
      it do
        is_expected.to contain("class User::ReadinessPolicy < Tram::Policy")
      end
      it { is_expected.to contain("param :user") }
      it do
        is_expected.to contain("option :name, default: -> { user.name }")
      end
      it do
        is_expected.to contain("option :email, default: -> { user.email }")
      end
    end

    describe "Spec file" do
      subject { file("spec/policies/user/readiness_policy.rb") }

      it { is_expected.to exist }
      it { is_expected.to contain("RSpec.describe User::ReadinessPolicy") }
      it { is_expected.to contain("let(:user) { build(:user) }") }
      it { is_expected.to contain("let(:policy) { described_class[user] }") }
      it { is_expected.to contain(/be_invalid_at field: "name"/) }
      it { is_expected.to contain(/be_invalid_at field: "email"/) }
    end
  end

  context "without attributes" do
    before(:all) do
      described_class.start %w[user/readiness_policy user], config
    end

    # I couldn't figure out, how to make Thor rewrite files
    # so for now clean them manually
    after(:all) do
      FileUtils.rm_rf(destination)
    end

    describe "Policy class" do
      subject { file("app/policies/user/readiness_policy.rb") }

      it { is_expected.to exist }
      it do
        is_expected.to contain("class User::ReadinessPolicy < Tram::Policy")
      end
      it { is_expected.to contain("param :user") }
      it do
        is_expected.not_to contain(/option/)
      end
    end

    describe "Spec file" do
      subject { file("spec/policies/user/readiness_policy.rb") }

      it { is_expected.to exist }
      it { is_expected.to contain("RSpec.describe User::ReadinessPolicy") }
      it { is_expected.to contain("let(:user) { build(:user) }") }
      it { is_expected.to contain("let(:policy) { described_class[user] }") }
      it { is_expected.not_to contain(/context/) }
    end
  end
end
