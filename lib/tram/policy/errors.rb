module Tram
  class Policy::Errors
    include Enumerable

    def initialize
      @messages = Set.new
    end

    def add(mess, tags = {})
      @messages.add Policy::Error.new(
        mess,
        tags
      )
    end

    def each
      @messages.each { |error| yield error }
    end

    def messages
      @messages.map{|m| m.message}
    end

    def full_messages
      @messages.map do |item|
        item.full_message
      end
    end

    alias filter select
  end
end
