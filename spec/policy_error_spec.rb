require 'spec_helper'
require 'sample_model'

describe Tram::Policy::Error do
  before(:all) do
    I18n.available_locales = [:en]
    I18n.backend.store_translations(:en, {
      'tram/policy': {
        empty_text: "Text is empty"
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
      expect(error.message).to eq("Text is empty")
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
end
