module Tram
  class Policy
    class ValidationError < RuntimeError
      attr_reader :policy

      def initialize(message, policy)
        @policy = policy
        super(message)
      end
    end
  end
end
