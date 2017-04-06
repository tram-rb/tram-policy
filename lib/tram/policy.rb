require "dry-initializer"
require "i18n"

module Tram
  class Policy
    extend Dry::Initializer::Mixin
    singleton_class.send(:alias_method, :[], :new)
  end
end
