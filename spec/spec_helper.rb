begin
  require "pry"
rescue
  nil
end
require "bundler/setup"
require "tram/policy"
require "tram/policy/matchers"
require "rspec/its"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # Prepare the Test namespace for constants defined in specs
  config.around(:each) do |example|
    Test = Class.new(Module)
    example.run
    Object.send :remove_const, :Test
  end
end
