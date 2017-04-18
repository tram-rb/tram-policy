require "spec_helper"

RSpec.describe Tram::Policy do
  context "Support following methods" do
    it { expect(Tram::Policy).to respond_to(:validate) }
    it { expect(Tram::Policy).to respond_to(:[]) }
    it { expect(Tram::Policy).to respond_to(:param) }
    it { expect(Tram::Policy).to respond_to(:option) }
    it { is_expected.to respond_to(:errors) }
    it { is_expected.to respond_to(:valid?) }
    it { is_expected.to respond_to(:invalid?) }
    it { is_expected.to respond_to(:validate!) }
    it { is_expected.to respond_to(:messages) }
    it { is_expected.to respond_to(:full_messages) }
  end

  context "Block checkers" do
    before do
      class Test
        attr_accessor :title, :subtitle, :text
      end

      class Test::ReadinessPolicy < Tram::Policy
        param  :article

        option :title,    proc(&:to_s), default: -> { article.title }
        option :subtitle, proc(&:to_s), default: -> { article.subtitle }
        option :text,     proc(&:to_s), default: -> { article.text }

        validate :title_presence, :subtitle_presence
        validate :text_presence

        private

        def title_presence
          return unless title.empty?
          errors.add "Title is empty", field: "title", level: "error"
        end

        def subtitle_presence
          return unless subtitle.empty?
          errors.add "Subtitle is empty", field: "subtitle", level: "warning"
        end

        def text_presence
          return unless text.empty?
          errors.add :empty_text, field: "text", level: "error"
        end
      end
    end

    let(:article) { Test.new }
    let(:policy) { Test::ReadinessPolicy[article] }

    it "#valid? include tag" do
      result = policy.valid? do |error|
        !%w[warning error].include? error.level
      end
      expect(result).to be false
    end

    it "#valid? tag not equal value" do
      result = policy.valid? { |error| error.level != "disaster" }
      expect(result).to be true
    end

    it "#invalid? include tag" do
      result = policy.invalid?{ |error| %w[warning error].include? error.level }
      expect(result).to be true
    end

    it "!#invalid? equal value" do
      result = policy.invalid? { |error| error.level == "disaster" }
      expect(result).to be false
    end

    it "#validate! tag not equal value" do
      result = policy.validate! do |error|
        error.level != "disaster"
      end
      expect(result).to be nil
    end

    it "#validate! equal value" do
      expect do
        policy.validate!{ |error| error.level == "disaster" }
      end.to raise_error(Tram::Policy::ValidationError)
    end
  end

  context "Policy not include validation method" do
    before do
      class Test::TestPolicy < Tram::Policy
        validate :title_precent
      end
    end

    it "method is missing" do
      expect{ Test::TestPolicy.new }.to raise_error(
        /undefined method `title_precent'/
      )
    end
  end

  context "Validate list of methods" do
    before do
      class Test::TestPolicy < Tram::Policy
        validate :title_precent, :body_present
        validate :text_present

        def title_precent; end

        def body_present; end

        def text_present; end
      end
    end

    it "respond list of methods" do
      policy = Test::TestPolicy.new
      expect(policy).to respond_to(:title_precent)
      expect(policy).to respond_to(:body_present)
      expect(policy).to respond_to(:text_present)
    end
  end

  context "Validate string method" do
    before do
      class Test::TestPolicy < Tram::Policy
        validate "title_precent"

        def title_precent; end
      end
    end

    it "respond string method" do
      policy = Test::TestPolicy.new
      expect(policy).to respond_to(:title_precent)
    end
  end

  context "Validate not uniq methods" do
    before do
      class Test::TestPolicy < Tram::Policy
        validate :title_precent, :title_precent, :title_precent

        def title_precent
          errors.add "Title is empty", field: "title", level: "error"
        end
      end
    end

    it "not uniq methods" do
      test_no_method_policy = Test::TestPolicy.new
      expect(test_no_method_policy.errors.count).to eql 1
    end
  end

  context "Validate the same field" do
    before do
      class Test::TestPolicy < Tram::Policy
        validate :title_precent, :title_uniqueness

        def title_precent
          errors.add "Title is empty", field: "title", level: "error"
        end

        def title_uniqueness
          errors.add "Title should be uniq", field: "title", level: "error"
        end
      end
    end

    it "the same field" do
      test_no_method_policy = Test::TestPolicy.new
      expect(test_no_method_policy.errors.count).to eql 2
    end
  end

  context "When policy composition" do
    before do
      class Test
        attr_accessor :title, :subtitle, :text
      end

      class Test::ReadinessPolicy < Tram::Policy
        param  :article

        option :title,    proc(&:to_s), default: -> { article.title }
        option :subtitle, proc(&:to_s), default: -> { article.subtitle }
        option :text,     proc(&:to_s), default: -> { article.text }

        validate :title_presence, :subtitle_presence
        validate :text_presence

        private

        def title_presence
          return unless title.empty?
          errors.add "Title is empty", field: "title", level: "error"
        end

        def subtitle_presence
          return unless subtitle.empty?
          errors.add "Subtitle is empty", field: "subtitle", level: "warning"
        end

        def text_presence
          return unless text.empty?
          errors.add "Text empty", field: "text", level: "error"
        end
      end

      class Test::PublicationPolicy < Tram::Policy
        param  :article

        validate :article_readiness

        private

        def article_readiness
          Test::ReadinessPolicy[article].errors.each do |err|
            next if err.level == "warning"
            errors.add err.to_h.merge({ field: "article[#{err.field}]" })
          end
        end
      end
    end

    let(:article) { Test.new }
    let(:policy) { Test::PublicationPolicy[article] }

    it "count nested validation" do
      expect(policy.errors.count).to be 2
    end

    it "nested validation messages" do
      expect(policy.errors.messages).to match_array([
        { message: "Title is empty", field: "article[title]", level: "error" },
        { message: "Text empty", field: "article[text]", level: "error" }
      ])
    end
  end
end
