require 'core_ext/string'

class TramPolicyGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  desc 'The gem provides simple tool for scaffolding new policy along with RSpec specification.
  `tram-policy user/readiness_policy user user:name user:email` or `rails g tram_policy user/readiness_policy user user:name user:email`
  will generate a corresponding class User::ReadinessPolicy and a specification, compatible to both RSpec and FactoryGirl readiness_policy_spec.rb'

  argument :file_name, type: :string
  argument :model, type: :string
  argument :policy_attributes, type: :array

  def copy_templates
    template "policy.rb", "app/policies/#{file_name}.rb"
    template "policy_spec.rb", "spec/policies/#{file_name}_spec.rb"
  end

  private
    def policy_name
      file_name.camelize
    end

    def attributes
      policy_attributes.map {|attribute| {model: attribute.split(':').first, name: attribute.split(':').last}}
    end
end
