class Hash
  def symbolize_keys
    Hash[map{ |k, v| [k.to_sym, v] }]
  end
end
