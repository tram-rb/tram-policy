require "thor"

module Tram
  class Generator < Thor
    include Thor::Actions
    desc "generate ARGS", "Generate a new policy"
    long_desc <<-EOS
    `generate ARGS` scaffolding new policy along with RSpec specification.
    $ > tram_policy generate user/readiness_policy user user:name user:email
    EOS

    argument :init_class_name, type: :string
    argument :init_params, type: :array

    source_root File.expand_path("../templates", __FILE__)

    # I don't get how to do it in a different way
    def generate
      copy_templates
    end

    no_commands do
      def camelize(input)
        # rubocop: disable Style/RegexpLiteral
        # rubocop: disable Style/PerlBackrefs
        # rubocop: disable Metrics/LineLength
        # Because copy from inflecto
        input.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:\A|_)(.)/) { $1.upcase }
      end

      def policy_options
        init_params.select{|e| /:/ =~ e}
      end

      def policy_params
        init_params.reject{|e| /:/ =~ e}
      end
    end

    protected

    def copy_templates
      template("dry_initializer.rb", "app/policies/#{init_class_name}.rb")
      template("dry_initializer_spec.rb", "spec/policies/#{init_class_name}.rb")
      template("dry_initializer_factories.rb", "spec/factories/policy.rb")
    end
  end
end
