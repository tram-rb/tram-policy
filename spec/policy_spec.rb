require 'spec_helper'
require 'sample_model'
require 'sample_policy'

describe Tram::Policy do
  before(:all) { I18n.available_locales = [:en] }
  let(:article) { Article.new title: 'A wonderful article', subtitle: '', text: '' }
  subject(:policy) { Article::ReadinessPolicy[article] }

  describe 'has class level-method' do
    context '.[]' do
      it { is_expected.to be_an_instance_of(Article::ReadinessPolicy) }

      it 'should memorize article in article attribute' do
        expect(policy.article).to eq(article)
      end

      it 'should memorize article attributes' do
        expect(policy.title).to eq('A wonderful article')
        expect(policy.subtitle).to eq('')
        expect(policy.text).to eq('')
      end
    end

    context '.validate' do
      it 'should add errors' do
        expect(policy.errors.size).to eq(2)
      end
    end
  end

  context '.valid?' do
    it 'should return false if some error exists' do
      expect(policy.valid? { |error| !%w(warning error).include? error.level }).to be_falsey
    end

    it 'should return true if no errors exist' do
      expect(policy.valid? { |error| error.level != "disaster" }).to be_truthy
    end
  end

  context '.invalid?' do
    it 'should  return true if some error exists' do
      expect(policy.invalid? { |error| %w(warning error).include? error.level }).to be_truthy
    end

    it 'should return false if no errors exist' do
      expect(policy.invalid? { |error| error.level == "disaster" }).to be_falsey
    end
  end

  context '.errors' do
    it 'should return an instance of Tram::Policy::Errors' do
      expect(policy.errors).to be_an_instance_of(Tram::Policy::Errors)
    end
  end

  context 'validate!' do
    it 'should raise exception if some error exists' do
      expect { policy.validate! { |error| !%w(warning error).include? error.level } }.to raise_error(Tram::Policy::ValidationError,
        'Subtitle is empty: {:field=>"subtitle", :level=>"warning"}. Error translation for missed text: {:field=>"text", :level=>"error"}')
    end

    it 'should not raise exception if no errors exist' do
      expect { policy.validate! { |error| error.level != "disaster" } }.not_to raise_error
    end
  end

  context '.invalid_at?' do
    it 'should return false if policy is valid' do
      expect(policy.invalid_at?(field: 'title')).to be_falsey
    end

    it 'should return messages of errors if policy is invalid' do
      expect(policy.invalid_at?(field: 'subtitle')).to eq('Policy is invalid: Subtitle is empty')
    end

    it 'should point to not translated errors if some translations was missed' do
      expect(policy.invalid_at?(field: 'text')).to eq('Policy is invalid: Error translation for missed text. ' +
        'Missed translations: en.article/readiness_policy.empty_subtitle')
    end
  end
end
