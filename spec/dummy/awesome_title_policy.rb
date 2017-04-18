module Dummy
  class AwesomeTitlePolicy < ReadinessPolicy
    validate :awesome_presence

    private

    def awesome_presence
      return if title =~ /awesome/i
      errors.add "Title is not awesome", field: "title", level: "warning"
    end
  end
end
