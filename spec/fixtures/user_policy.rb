class Test::UserPolicy < Tram::Policy
  param :user

  validate "name"
  validate "email"
  validate "name"

  private

  def name
    errors.add "No name", level: "warning" unless user.name
  end

  def email
    user.email
  end

  def login
    user.login
  end
end
