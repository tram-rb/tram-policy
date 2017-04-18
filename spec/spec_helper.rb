require "bundler/setup"
require "tram/policy"
require "rspec/tram/policy/matchers"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.warnings = true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # Prepare the Test namespace for constants defined in specs
  config.around(:each) do |example|
    I18n.load_path = Dir["./spec/locales/*.yml"]
    Test = Class.new(Module)
    example.run
    Object.send :remove_const, :Test
  end
end
