require 'spec_helper'

describe Tram::Policy::ValidationError do
  let(:policy) { Tram::Policy.new(Article.new) }
  subject(:error) { Tram::Policy::ValidationError.new(policy, policy.errors) }

  it { expect(described_class).to be < RuntimeError }

  context '.policy' do
    it 'should return policy' do
      expect(error.policy).to eq(policy)
    end
  end
end
