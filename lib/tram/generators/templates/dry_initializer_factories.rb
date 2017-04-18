<% policy_params.each do |param| -%>
FactoryGirl.define do
  factory :<%= param %> do
  end
end
<% end %>
