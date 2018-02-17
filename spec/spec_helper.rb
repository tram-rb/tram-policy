require "bundler/setup"
require "tram/policy"
require "tram/policy/rspec"
require "rspec/its"

require_relative "support/fixtures_helper.rb"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:each) do
    Test = Class.new(Module)
    I18n.available_locales = %w[en]
    I18n.backend.store_translations :en, yaml_fixture_file("en.yml")["en"]
  end

  config.after(:each) { Object.send :remove_const, :Test }
end
