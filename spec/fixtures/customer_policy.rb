class Test::CustomerPolicy < Tram::Policy
  option :name

  validate do
    return if name
    errors.add :name_presence, field: "name"
  end
end
