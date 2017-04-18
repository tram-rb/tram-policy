class <%= policy_name %> < Tram::Policy
  param  :<%= model %>

<% attributes.each do |attribute| -%>
  option :<%= attribute[:name] %>,  default: -> { <%= attribute[:model] %>.<%= attribute[:name] %> }
<% end -%>
end
