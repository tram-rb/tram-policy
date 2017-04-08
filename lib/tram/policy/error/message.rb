module Tram
  class Policy
    class Error
      class Message
        extend Dry::Initializer

        param :content
        option :translation_scope, default: -> { nil }
        option :variables, default: -> { {} }

        def to_s
          return @content unless @content.is_a? Symbol

          I18n.t(
            @content,
            @variables.merge(scope: @translation_scope)
          )
        end
      end
    end
  end
end
