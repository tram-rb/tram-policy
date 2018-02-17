RSpec.describe "RSpec support:" do
  subject { Test::CustomerPolicy[name: nil] }

  before do
    I18n.available_locales = %i[en]
    I18n.backend.store_translations :en, yaml_fixture_file("en.yml")["en"]
    load_fixture "customer_policy.rb"
  end

  describe "to be_invalid_at" do
    it "passes when some translated error present w/o tags constraint" do
      expect { expect(subject).to be_invalid_at }.not_to raise_error
    end

    it "passes when some translated error present under given tags" do
      expect { expect(subject).to be_invalid_at field: "name" }
        .not_to raise_error
    end

    it "fails when no errors present under given tags" do
      expect { expect(subject).to be_invalid_at field: "email" }
        .to raise_error RSpec::Expectations::ExpectationNotMetError
    end

    it "fails when some translations are absent" do
      I18n.available_locales = %i[ru en]

      expect { expect(subject).to be_invalid_at field: "name" }
        .to raise_error RSpec::Expectations::ExpectationNotMetError
    end
  end

  describe "not_to be_invalid_at" do
    it "passes when no errors present under given tags" do
      expect { expect(subject).not_to be_invalid_at field: "email" }
        .not_to raise_error
    end

    it "fails when some error present under given tags" do
      expect { expect(subject).not_to be_invalid_at field: "name" }
        .to raise_error RSpec::Expectations::ExpectationNotMetError
    end

    it "fails when some error present w/o tags constraint" do
      expect { expect(subject).not_to be_invalid_at }
        .to raise_error RSpec::Expectations::ExpectationNotMetError
    end
  end
end
