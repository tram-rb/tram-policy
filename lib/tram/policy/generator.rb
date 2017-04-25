require "thor/group"
require "i18n"

module Tram
  class Policy
    require_relative "inflector"

    class Generator < Thor::Group
      include Thor::Actions

      desc "Generates new policy class along with its specification"
      argument :name, desc: "policy class name", type: :string
      class_option :params,     desc:    "list of policy params",
                                type:    :array,
                                default: [],
                                aliases: "-p",
                                banner:  "param[ param]"
      class_option :options,    desc:    "list of policy options",
                                type:    :array,
                                default: [],
                                aliases: "-o",
                                banner:  "option[ option]"
      class_option :validators, desc:    "list of policy validators",
                                type:    :array,
                                default: [],
                                aliases: "-v",
                                banner:  "validator[ validator]"
      class_option :locales,    desc:    "list of available_locales",
                                type:    :array,
                                default: [],
                                aliases: "-l",
                                banner:  "en[ ru]"

      def self.source_root
        File.dirname(__FILE__)
      end

      def set_available_locales
        @available_locales = \
          if Array(options[:locales]).any?
            options[:locales]
          else
            ask("Enter available locales for translation:").scan(/\w{2}/)
          end
      end

      def generate_class
        template "generator/policy.erb", "app/policies/#{file}.rb"
      end

      def generate_locales
        available_locales.each do |locale|
          @locale = locale
          add_locale
          localize_policy
          parsed_validators.sort_by { |v| v[:key] }
                           .each { |validator| localize_validator(validator) }
        end
      end

      def generate_spec
        template "generator/policy_spec.erb", "spec/policies/#{file}_spec.rb"
      end

      no_tasks do
        def available_locales
          @available_locales ||= []
        end

        def klass
          @klass ||= Inflector.camelize name
        end

        def file
          @file ||= Inflector.underscore name
        end

        def parsed_options
          @parsed_options ||= options[:options].map(&:downcase)
        end

        def parsed_params
          @parsed_params ||= options[:params].map(&:downcase)
        end

        def parsed_validators
          @parsed_validators ||= options[:validators].map do |str|
            name, key = str.downcase.split(":")
            { name: name, key: key || name }
          end
        end

        def policy_signature
          @policy_signature ||= (
            parsed_params + \
            parsed_options.map { |option| "#{option}: #{option}" }
          ).join(", ")
        end

        def locale_file
          "config/locales/tram-policy.#{@locale}.yml"
        end

        def locale_header
          "---\n#{@locale}:\n"
        end

        def locale_group
          @locale_group ||= "  #{file}:\n"
        end

        def locale_line(key)
          "    #{key}: translation missing\n"
        end

        def add_locale
          create_file(locale_file, skip: true) { locale_header }
        end

        def localize_policy
          append_to_file(locale_file, locale_group)
        end

        def localize_validator(key:, **)
          insert_into_file locale_file, locale_line(key), after: locale_group
        end
      end
    end
  end
end
