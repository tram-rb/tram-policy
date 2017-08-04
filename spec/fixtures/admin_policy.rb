require_relative "user_policy"

class Test::AdminPolicy < Test::UserPolicy
  validate :login
  validate :name
end
