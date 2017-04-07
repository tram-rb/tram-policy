RSpec.describe Tram::Policy::ValidationError do
  it "should inherit from RuntimeError" do
    expect(described_class).to be < RuntimeError
  end
end
