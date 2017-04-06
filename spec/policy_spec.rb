require 'spec_helper'
require 'sample_model'
require 'sample_policy'

describe Tram::Policy do
  before(:all) do
    @article = Article.new title: 'A wonderful article', subtitle: '', text: ''
    @policy = Article::ReadinessPolicy[@article]
  end

  context '[] method' do
    it 'should create instance of sample policy class' do
      expect(@policy).to be_an_instance_of(Article::ReadinessPolicy)
    end

    it 'should memorize article in article attribute' do
      expect(@policy.article).to eq(@article)
    end

    it 'should memorize article attributes' do
      expect(@policy.title).to eq('A wonderful article')
      expect(@policy.subtitle).to eq('')
      expect(@policy.text).to eq('')
    end
  end
end
