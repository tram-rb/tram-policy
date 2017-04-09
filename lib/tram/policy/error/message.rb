module Tram
  class Policy
    class Error
      # This class was introduced with purpose to
      # decouple Error and the "parent" policy class.
      # We need the last to determine i18n scope, and
      # we need to store it somewhere for the case of
      # sequential translations with different locales.
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
