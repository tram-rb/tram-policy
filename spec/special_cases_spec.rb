describe "Special cases" do
  before(:all) do
    I18n.load_path = Dir["./spec/locales/*.yml"]

    class Post
      attr_accessor :title, :subtitle, :text
    end

    class AdminPost
      attr_accessor :title, :subtitle, :text
    end

    class SuperAdmin
      attr_accessor :title, :subtitle, :text
    end

    class Post::ReadinessPolicy < Tram::Policy
      param  :article

      option :title,    proc(&:to_s), default: -> { article.title }
      option :subtitle, proc(&:to_s), default: -> { article.subtitle }
      option :text,     proc(&:to_s), default: -> { article.text }

      validate :title_presence

      private

      def title_presence
        return unless title.empty?
        errors.add "Title is empty", field: "title", level: "error"
      end
    end

    class AdminPost::ReadinessPolicy < Post::ReadinessPolicy
      validate :text_presence

      protected

      def text_presence
        return unless text.empty?
        errors.add :empty_text, field: "text", level: "error"
      end
    end

    class SuperAdmin::ReadinessPolicy < AdminPost::ReadinessPolicy
      validate :subtitle_presence

      def subtitle_presence
        return unless subtitle.empty?
        errors.add "Subtitle is empty", field: "subtitle", level: "warning"
      end
    end

    class SuperAdmin::TestPolicy < SuperAdmin::ReadinessPolicy
      validate :subtitle_presence

      def subtitle_presence
        return unless subtitle.empty?
        errors.add "Bla bla", field: "subtitle", level: "warning"
      end
    end
  end

  context "When no inheritance" do
    let(:post) { Post.new }
    let(:policy) { Post::ReadinessPolicy[post] }

    it "must return one error" do
      expect(policy.errors.count).to eq 1
    end
  end

  context "When inheritance and private methods" do
    let(:post) { AdminPost.new }
    let(:policy) { AdminPost::ReadinessPolicy[post] }

    it "must return one error" do
      expect(policy.errors.count).to eq 1
    end
  end

  context "When inheritance and protected methods" do
    let(:post) { SuperAdmin.new }
    let(:policy) { SuperAdmin::ReadinessPolicy[post] }

    it "must return two errors" do
      expect(policy.errors.count).to eq 2
    end
  end

  context "Override validation method during inheritance" do
    let(:post) { SuperAdmin.new }
    let(:policy) { SuperAdmin::TestPolicy[post] }

    it "must override validation method" do
      expect(policy.errors.messages).to include "Bla bla"
    end
  end
end
