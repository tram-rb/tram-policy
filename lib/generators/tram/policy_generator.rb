require "thor/group"

module Tram
  module Generators
    class PolicyGenerator < Thor::Group
      include Thor::Actions

      desc "Generates new policy class with specs"
      argument :policy_name, type: :string, desc: "module/class"
      argument :model, type: :string, desc: "model"
      class_option :attributes,
                   type: :array,
                   optional: true,
                   desc: "model: field_name"

      def self.source_root
        File.dirname(__FILE__)
      end

      def generate_class
        template("templates/policy_class.erb", "app/policies/#{policy_name}.rb")
      end

      def generate_spec
        template(
          "templates/policy_class_spec.erb",
          "spec/policies/#{policy_name}.rb"
        )
      end

      no_tasks do
        def camelize(string)
          string.split("_").map(&:capitalize).join
        end

        def policy_class_name
          policy_name.split("/").map { |part| camelize(part) }.join("::")
        end

        def parsed_attributes
          return [] unless options[:attributes]

          options[:attributes].map do |attr|
            model, name = attr.split(":")
            { model: model, name: name }
          end
        end
      end
    end
  end
end
