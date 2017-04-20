RSpec.describe "RSpec support:" do
  subject { Test::UserPolicy[name: nil] }

  before do
    I18n.available_locales = %i[en]
    I18n.backend.store_translations \
      :en, { "test/user_policy" => { "name_presence" => "Name is absent" } }

    class Test::UserPolicy < Tram::Policy
      option :name

      validate :name_presence

      private

      def name_presence
        return if name
        errors.add :name_presence, field: "name"
      end
    end
  end

  describe "to be_invalid_at" do
    it "passes when some translated error present w/o tags constraint" do
      expect do
        expect { subject }.to be_invalid_at
      end.not_to raise_error
    end

    it "passes when some translated error present under given tags" do
      expect do
        expect { subject }.to be_invalid_at field: "name"
      end.not_to raise_error
    end

    it "fails when no errors present under given tags" do
      expect do
        expect { subject }.to be_invalid_at field: "email"
      end.to raise_error RSpec::Expectations::ExpectationNotMetError
    end

    it "fails when some translations are absent" do
      I18n.available_locales = %i[ru en]

      expect do
        expect { subject }.to be_invalid_at field: "name"
      end.to raise_error RSpec::Expectations::ExpectationNotMetError
    end
  end

  describe "not_to be_invalid_at" do
    it "passes when no errors present under given tags" do
      expect do
        expect { subject }.not_to be_invalid_at field: "email"
      end.not_to raise_error
    end

    it "fails when some error present under given tags" do
      expect do
        expect { subject }.not_to be_invalid_at field: "name"
      end.to raise_error RSpec::Expectations::ExpectationNotMetError
    end

    it "fails when some error present w/o tags constraint" do
      expect do
        expect { subject }.not_to be_invalid_at
      end.to raise_error RSpec::Expectations::ExpectationNotMetError
    end
  end

  describe "shared examples" do
    it_behaves_like :invalid_policy
    it_behaves_like :invalid_policy, field: "name" do
      before { I18n.available_locales = %i[en ru] }
    end
    it_behaves_like :valid_policy,   field: "email"
  end
end
