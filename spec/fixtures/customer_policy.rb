class Test::CustomerPolicy < Tram::Policy
  option :name

  validate { errors.add :name_presence, field: "name" unless name }
end
