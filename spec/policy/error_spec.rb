require 'spec_helper'
require 'sample_model'

describe Tram::Policy::Error do
  before(:all) do
    I18n.available_locales = [:en]
    I18n.backend.store_translations(:en, {
      'tram/policy': {
        empty_text: "Validation %{level}: %{field} is empty"
      }
    })

    @policy = Tram::Policy.new(Article.new)
    @error = Tram::Policy::Error.new(@policy, "Title is empty", field: "title", level: "error")
  end

  context '.tags' do
    it 'should return hash of assigned tags' do
      expect(@error.tags).to eq({field: "title", level: "error"})
    end
  end

  context '.message' do
    it 'should return message itself if message is string' do
      expect(@error.message).to eq("Title is empty")
    end

    it 'should return default message if message is symbol and translation is missed' do
      error = Tram::Policy::Error.new(@policy, :empty_text, field: "text", level: "error")
      expect(error.message).to eq("Validation error: text is empty")
    end

    it 'should return translated message if message is symbol and translation exists' do
      error = Tram::Policy::Error.new(@policy, :too_long, field: "text", level: "error")
      expect(error.message).to eq("Error translation for missed text")
    end
  end

  context '.full_message' do
    it 'should return the message with tags info added' do
      expect(@error.full_message).to eq("Title is empty: {:field=>\"title\", :level=>\"error\"}")
    end
  end

  context '.to_h' do
    it 'should return hash of tags and a message' do
      expect(@error.to_h).to eq({message: "Title is empty", field: "title", level: "error"})
    end
  end

  context '==' do
    it 'should check whether an error is equal to another one' do
      error = Tram::Policy::Error.new(@policy, "Title is empty", field: "title", level: "error")
      equality = @error == error
      expect(equality).to be_truthy
    end
  end

  context 'undefined methods treated as tags' do
    it { expect(@error.field).to eq('title') }
    it { expect(@error.level).to eq('error') }
    it { expect { @error.time }.to raise_error(NoMethodError) }
  end

  context '.missed_translations' do
    it 'should return empty error if message is string' do
      expect(@error.missed_translations).to eq(Array.new)
    end

    it 'should return empty error if message is symbol and there are not missed translations' do
      error = Tram::Policy::Error.new(@policy, :empty_text, field: "text", level: "error")
      expect(error.missed_translations).to eq(Array.new)
    end

    it 'should return array of missed translations if they exist' do
      I18n.available_locales = [:en, :ru, :de]
      error = Tram::Policy::Error.new(@policy, :empty_text, field: "text", level: "error")
      expect(error.missed_translations).to eq(['ru.tram/policy.empty_text', 'de.tram/policy.empty_text'])
      I18n.available_locales = [:en]
    end
  end
end
