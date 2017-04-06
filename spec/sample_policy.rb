class Article::ReadinessPolicy < Tram::Policy
  param  :article

  option :title,    proc(&:to_s), default: -> { article.title }
  option :subtitle, proc(&:to_s), default: -> { article.subtitle }
  option :text,     proc(&:to_s), default: -> { article.text }
end
