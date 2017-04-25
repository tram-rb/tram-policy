module Tram
  class Policy::ValidationError < RuntimeError
    attr_reader :policy, :messages

    def initialize(policy)
      message = build_message(policy.errors.full_messages)
      super(message)
      @policy = policy
    end

    def build_message(messages)
      "Policy validation failed with messages: #{messages.join(', ')}"
    end
  end
end
