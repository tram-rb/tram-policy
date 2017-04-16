RSpec.describe Tram::Policy::ValidationError do
  subject(:error) { described_class.new policy, filter }

  let(:one)    { double full_message: "OMG!",  level: "error" }
  let(:two)    { double full_message: "phew!", level: "warning" }
  let(:policy) { double :policy, errors: [one, two] }

  shared_examples :exception_with_messages do |text|
    it { is_expected.to be_a RuntimeError }
    its(:policy)  { is_expected.to eq policy }
    its(:message) { is_expected.to eq "Validation failed with errors:#{text}" }
  end

  context "with a liberal filter" do
    let(:filter) { proc { false } }
    it_behaves_like :exception_with_messages, "\n- OMG!\n- phew!"
  end

  context "with a restricting filter" do
    let(:filter) { proc { |error| error.level != "error" } }
    it_behaves_like :exception_with_messages, "\n- OMG!"
  end
end
