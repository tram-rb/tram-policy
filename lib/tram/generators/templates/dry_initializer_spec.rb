RSpec.describe <%= camelize(init_class_name) %> do
<% policy_params.each do |param| -%>
  let(:<%= param %>)   { build :<%= param %> }
  let(:policy) { described_class[<%= param %>] }
<% end %>
  it { is_expected.to be_valid }
<% policy_options.each do |option| -%>
  context "with wrong <%= option.split(":").last %>" do
    before { <%= option.gsub(":",".")%> = nil }
    it { is_expected.to be_invalid_at field: "<%= option.split(":").last %>" }
  end
<% end %>
end
