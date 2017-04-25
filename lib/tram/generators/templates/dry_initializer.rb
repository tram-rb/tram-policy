class <%= camelize(init_class_name) %> < Tram::Policy
<% policy_params.each do |param| -%>
  param  :<%= param %>
<% end %>
<% policy_options.each do |option| -%>
  option :<%= option.split(":").last %>, default: -> { <%= option.gsub(':','.') %> }
<% end -%>
end
