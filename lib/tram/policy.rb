require "dry-initializer"
require "i18n"

module Tram
  # Base class for policy objects with composable validation errors
  class Policy
    require_relative "policy/validation_error"
    require_relative "policy/inflector"
    require_relative "policy/error"
    require_relative "policy/errors"
  end
end
