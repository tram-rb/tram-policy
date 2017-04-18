require "thor/group"

module Tram
  class Policy
    module Generators
      class PolicyGenerator < Thor::Group
        include Thor::Actions

        desc "Generates new policy class and the spec for it " \
              "and places it in the `app/policies` and `spec/policies` " \
              "correspondingly"

        argument :policy_name,
                 type: :string,
                 desc: "policy class name in snake case, " \
                        "modules separated with slashes"
        argument :model, type: :string, desc: "model under the policy"
        argument :attributes,
                 type: :array,
                 optional: true,
                 desc: "list of model attributes, that will be injected into" \
                        "policy. Format: `model_name:attr1 model_name:attr2..."

        def self.source_root
          File.dirname(__FILE__)
        end

        def generate_class
          template(
            "templates/policy_class.erb",
            "app/policies/#{policy_name}.rb"
          )
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
            return [] unless attributes

            attributes.map do |attr|
              model, name = attr.split(":")
              { model: model, name: name }
            end
          end
        end
      end
    end
  end
end
