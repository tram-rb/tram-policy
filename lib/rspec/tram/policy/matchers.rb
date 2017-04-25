require "rspec/core"
require "rspec/expectations"
require "rspec/tram/policy/matchers/be_invalid_at"
RSpec.configure do |config|
  config.include Tram::Policy::Matchers
end
