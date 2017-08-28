class Test::AdminPolicy < Test::UserPolicy
  validate :login
  validate :name
end
