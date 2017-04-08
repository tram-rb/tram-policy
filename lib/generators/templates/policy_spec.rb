RSpec.describe <%= policy_name %> do
  let(:<%= model %>)   { build :<%= model %> }
  subject(:policy) { described_class[<%= model %>] }

  it { is_expected.to be_valid }

<% attributes.each do |attribute| -%>
  context "with wrong <%= attribute[:name] %>" do
    before { <%= attribute[:model] %>.<%= attribute[:name] %> = nil }
    it { is_expected.to be_invalid_at field: "<%= attribute[:name] %>" }
  end

<% end -%>
end
