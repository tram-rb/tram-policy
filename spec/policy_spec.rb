require 'spec_helper'
require 'sample_model'
require 'sample_policy'

describe Tram::Policy do
  before(:all) do
    I18n.available_locales = [:en]

    @article = Article.new title: 'A wonderful article', subtitle: '', text: ''
    @policy = Article::ReadinessPolicy[@article]
  end

  describe 'has class level-method' do
    context '.[]' do
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

    context '.validate' do
      it 'should add errors' do
        expect(@policy.errors.size).to eq(2)
      end
    end
  end

  context '.valid?' do
    it 'should  return false if some error exists' do
      expect(@policy.valid?).to be_falsey
    end

    it 'should return true if no errors exist' do
      article = Article.new title: 'title', subtitle: 'subtitle', text: 'text'
      expect(Article::ReadinessPolicy[article].valid?).to be_truthy
    end
  end

  context '.invalid?' do
    it 'should  return true if some error exists' do
      expect(@policy.invalid?).to be_truthy
    end

    it 'should return false if no errors exist' do
      article = Article.new title: 'title', subtitle: 'subtitle', text: 'text'
      expect(Article::ReadinessPolicy[article].invalid?).to be_falsey
    end
  end

  context '.errors' do
    it 'should return an instance of Tram::Policy::Errors' do
      expect(@policy.errors).to be_an_instance_of(Tram::Policy::Errors)
    end
  end

  context 'validate!' do
    it 'should raise exception if some error exists' do
      expect { @policy.validate! }.to raise_error(Tram::Policy::ValidationError)
    end

    it 'should not raise exception if no errors exist' do
      article = Article.new title: 'title', subtitle: 'subtitle', text: 'text'
      expect { Article::ReadinessPolicy[article].validate! }.not_to raise_error
    end
  end

  context '.invalid_at?' do
    it 'should return false if policy is valid' do
      expect(@policy.invalid_at?(field: 'title')).to be_falsey
    end

    it 'should return messages of errors if policy is invalid' do
      expect(@policy.invalid_at?(field: 'subtitle')).to eq('Policy is invalid: Subtitle is empty')
    end

    it 'should point to not translated errors if some translations was missed' do
      expect(@policy.invalid_at?(field: 'text')).to eq('Policy is invalid: Error translation for missed text. Missed translations: en.article/readiness_policy.empty_subtitle')
    end
  end
end
