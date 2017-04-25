require "spec_helper"

RSpec.describe Tram::Policy::ValidationError do
  before do
    class Test::SalePolicy < Tram::Policy
      option :price, default: proc { 0 }

      validate :price_precent

      def price_precent
        return if price > 0
        errors.add "Price is 0", filed: "price", level: "warning"
      end
    end
  end

  let(:policy) {Test::SalePolicy.new}
  let(:tram_policy_validation) {Tram::Policy::ValidationError.new(policy)}

  it "returns a policy object that raised an exception" do
    expect(tram_policy_validation.policy.object_id).to eql(policy.object_id)
  end

  it "exception message" do
    expect{policy.validate!}.to raise_error(
      "Policy validation failed with messages: "\
      "Price is 0: {:filed=>\"price\", :level=>\"warning\"}"
    )
  end
end
