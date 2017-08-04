class Test::CustomerPolicy < Tram::Policy
  option :name

  validate :name_presence

  private

  def name_presence
    return if name
    errors.add :name_presence, field: "name"
  end
end
