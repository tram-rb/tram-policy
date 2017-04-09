RSpec.describe Tram::Policy::Errors do
  subject { build(:errors) }

  it "should be Enumerable" do
    expect(subject).to be_kind_of Enumerable
    expect(subject).to respond_to :each
  end

  describe "#add" do
    it "should add error to list" do
      expect(subject.count).to eq(0)
      subject.add("Test error", { field: "name" })
      expect(subject.count).to eq(1)
      expect(subject.first).to be_kind_of Tram::Policy::Error
    end
  end
end
