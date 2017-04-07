module Dummy
  class ReadinessPolicy < Tram::Policy
    param :article
    option :title, proc(&:to_s), default: -> { article.title }
    option :subtitle, proc(&:to_s), default: -> { article.subtitle }
    option :text, proc(&:to_s), default: -> { article.text }

    validate :title_presence
    validate :subtitle_presence
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
