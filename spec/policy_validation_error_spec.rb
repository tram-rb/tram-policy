require 'spec_helper'

describe Tram::Policy::ValidationError do
  before(:all) do
    @policy = Tram::Policy.new(Article.new)
    @error = Tram::Policy::ValidationError.new(@policy)
  end

  it { expect(described_class).to be < RuntimeError }

  context '.policy' do
    it 'should return policy' do
      expect(@error.policy).to eq(@policy)
    end
  end
end
