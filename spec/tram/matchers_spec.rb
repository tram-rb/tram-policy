describe "be_invalid_at matcher" do
  let(:article) { build(:article) }
  let(:policy) { Dummy::ReadinessPolicy[article] }

  it "doesn't match valid policy" do
    expect(policy).not_to be_invalid_at(field: "title", level: "error")
  end

  it "matches invalid policy, that has an error with any of given tags" do
    article.title = nil

    expect(policy).to be_invalid_at(field: "title", level: "error")
    expect(policy).to be_invalid_at(level: "error")
    expect(policy).to be_invalid_at(field: "title")
    expect(policy).not_to be_invalid_at(field: "text")
  end

  it "provides description with tags list" do
    matcher = be_invalid_at(field: "title", level: "error")

    article.title = nil
    matcher.matches?(policy)

    expect(matcher.description).to \
      eq("be invalid at field: title and level: error")
  end

  it "provides description with single tag" do
    matcher = be_invalid_at(field: "text")

    article.text = nil
    matcher.matches?(policy)

    expect(matcher.description).to eq("be invalid at field: text")
  end
end
