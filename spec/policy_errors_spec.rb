require 'spec_helper'
require 'sample_model'

describe Tram::Policy::Errors do
  before(:each) do
    policy = Tram::Policy.new(Article.new)
    @errors = Tram::Policy::Errors.new(policy)

    @errors.add "Title is empty", field: "title", level: "error"
    @errors.add "Subtitle is empty", field: "subtitle", level: "warning"
  end

  it 'should support methods of enumerables' do
    expect(@errors.each.is_a?(Enumerator)).to be_truthy
    expect(@errors.sort_by.is_a?(Enumerator)).to be_truthy
  end

  context '.add' do
    it 'should add error' do
      @errors.add 'Title is too long', field: :title, label: :error
      expect(@errors.size).to eq(3)
    end
  end

  context '.clear' do
    it 'should clear collection of errors' do
      @errors.clear
      expect(@errors.size).to eq(0)
    end
  end

  context '.messages' do
    it 'should return an array of messages' do
      expect(@errors.messages).to eq(["Title is empty", "Subtitle is empty"])
    end
  end

  context '.full_messages' do
    it 'should return an array of messages with tags info added' do
      expect(@errors.full_messages).to eq(["Title is empty: {:field=>\"title\", :level=>\"error\"}",
        "Subtitle is empty: {:field=>\"subtitle\", :level=>\"warning\"}"])
    end
  end
end
