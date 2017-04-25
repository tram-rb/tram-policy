require "spec_helper"

RSpec.describe Tram::Policy::Errors do
  let(:tram_policy_errors) { Tram::Policy::Errors.new }

  context "Support following methods" do
    it { expect(tram_policy_errors).to respond_to(:add) }
    it { expect(tram_policy_errors).to respond_to(:each) }
    it { expect(tram_policy_errors).to respond_to(:messages) }
    it { expect(tram_policy_errors).to respond_to(:full_messages) }
  end

  it "#add" do
    tram_policy_errors.add("Title is empty", { field: "title", level: "error" })
    expect(tram_policy_errors.count).to eq(1)
  end

  it "#any?" do
    tram_policy_errors.add("Title is empty", { field: "title", level: "error" })
    expect(tram_policy_errors.any?).to be true
  end

  context "When duble message, tags" do
    it "same message and tags" do
      tram_policy_errors.add(
        "Title is empty",
        { field: "title", level: "error" }
      )
      tram_policy_errors.add(
        "Title is empty",
        { field: "title", level: "error" }
      )
      expect(tram_policy_errors.count).to eq 1
    end

    it "same message and diff tags value" do
      tram_policy_errors.add(
        "Title is empty",
        { field: "title", level: "error" }
      )
      tram_policy_errors.add(
        "Title is empty",
        { field: "admin_title", level: "error" }
      )
      expect(tram_policy_errors.count).to eq 2
    end

    it "same message and diff tags level" do
      tram_policy_errors.add(
        "Title is empty",
        { field: "title", level: "error" }
      )
      tram_policy_errors.add(
        "Title is empty",
        { field: "admin_title", level: "warning" }
      )
      expect(tram_policy_errors.count).to eq 2
    end

    it "same tags and diff message" do
      tram_policy_errors.add(
        "Title is empty",
        { field: "title", level: "error" }
      )
      tram_policy_errors.add(
        "Title empty",
        { field: "title", level: "error" }
      )
      expect(tram_policy_errors.count).to eq 2
    end
  end

  context "Loack at errors closer" do
    before do
      tram_policy_errors.add(
        "Title is empty",
        { field: "title", level: "error" }
      )
      tram_policy_errors.add(
        "Label is empty",
        { field: "label", level: "error" }
      )
    end

    it "#messages" do
      expect(tram_policy_errors.messages).to match_array \
        ["Title is empty", "Label is empty"]
    end

    it "#full_messages" do
      expect(tram_policy_errors.full_messages).to match_array [
        "Title is empty: {:field=>\"title\", :level=>\"error\"}",
        "Label is empty: {:field=>\"label\", :level=>\"error\"}"
      ]
    end

    it "#tags level" do
      expect(tram_policy_errors.filter do |error|
        error.tags[:level] == "error"
      end.count).to be 2
    end

    it "#tags field" do
      expect(tram_policy_errors.filter do |error|
        error.tags[:field] == "title"
      end.count).to be 1
    end

    it "#errors level" do
      expect(tram_policy_errors.filter do |error|
        error.level == "error"
      end.count).to be 2
    end

    it "#errors field" do
      expect(tram_policy_errors.filter do |error|
        error.field == "title"
      end.count).to be 1
    end
  end

  context "when tag is empty" do
    before do
      tram_policy_errors.add("Title is empty")
      tram_policy_errors.add("Name is empty")
    end

    it "#full_messages" do
      expect(tram_policy_errors.full_messages).to match_array [
        "Title is empty",
        "Name is empty"
      ]
    end
  end
end
