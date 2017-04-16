class Tram::Policy
  if Object.const_defined? "ActiveSupport::Inflector"
    Inflector = ActiveSupport::Inflector
  elsif Object.const_defined? "Inflecto"
    Inflector = ::Inflecto
  else
    module Inflector
      def self.underscore(name)
        name.dup.tap do |n|
          n.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          n.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
          n.gsub!("::", "/")
          n.tr!("-", "_")
          n.downcase!
        end
      end

      def self.camelize(name)
        name.dup.tap do |n|
          n.gsub!(/(?:\A|_+)(.)/)    { $1.upcase }
          n.gsub!(%r{(?:[/|-]+)(.)}) { "::#{$1.upcase}" }
        end
      end
    end
  end
end
