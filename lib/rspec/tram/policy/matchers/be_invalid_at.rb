module Tram
  module Policy::Matchers
    extend RSpec::Matchers::DSL

    matcher :be_invalid_at do |input|
      match do |policy|
        @fail_messages = []
        input.each do |key, val|
          if policy.errors.select { |error| error.tags[key] }.count != 1
            @fail_messages << "tag '#{key}' not include in given tags"
          end
          if policy.errors.select { |error| error.tags[key] == val }.count != 1
            @fail_messages << "'#{val}' not include in policy error"
          end
        end

        policy.errors.messages.each do |error|
          if error.match(/translation missing:/)
            @fail_messages << "translation missing: #{input}"
          end
        end

        !@fail_messages.any?
      end

      failure_message do
        @fail_messages.join("\n")
      end
    end
  end
end
