module Tram
  class Policy::Inflector
    def self.translate(base)
      @base = base
    end

    def self.generate(param, tags)
      return param unless param.is_a? Symbol
      key = [underscore(@base.class.name), param].join(".")
      I18n.translate(key, tags)
    end

    # Stolen from gem inflecto
    def self.underscore(input)
      word = input.gsub(/::/, "/")
      underscorize(word)
    end

    def self.underscorize(word)
      word.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end
  end
end
