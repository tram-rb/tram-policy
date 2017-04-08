require "bundler/setup"
require "tram-policy"
require "factory_girl"
require "byebug"

I18n.load_path = [File.dirname(__FILE__) + "/locales/en.yml"]
I18n.locale = :en

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.example_status_persistence_file_path = ".rspec_status"
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:suite) do
    FactoryGirl.find_definitions
  end

  # Prepare the Test namespace for constants defined in specs
  config.around(:each) do |example|
    Test = Class.new(Module)
    example.run
    Object.send :remove_const, :Test
  end
end
