# frozen_string_literal: true

require "rails_helper"

RSpec.describe DescriptionList::Component, type: :component do
  subject(:dl) { component.at_css("dl") }

  let(:component) { render_inline(described_class.new(rows:)) }
  let(:rows) do
    [
      { key: { text: "Label 1" }, value: { text: "Value 1" } },
      { key: { text: "Label 2" }, value: { text: "Value 2" } },
    ]
  end

  it "has the class" do
    expect(dl["class"]).to eq("app-description-list")
  end

  describe "first item" do
    let(:dt) { component.css("dt")[0] }
    let(:dd) { component.css("dd")[0] }

    it "has the class" do
      expect(dt["class"]).to eq("app-description-list__label")
    end

    it "has the label text" do
      expect(dt.text.strip).to eq("Label 1")
    end

    it "has the value text" do
      expect(dd.text.strip).to eq("Value 1")
    end
  end

  describe "second item" do
    let(:dt) { component.css("dt")[1] }
    let(:dd) { component.css("dd")[1] }

    it "has the class" do
      expect(dt["class"]).to eq("app-description-list__label")
    end

    it "has the label text" do
      expect(dt.text.strip).to eq("Label 2")
    end

    it "has the value text" do
      expect(dd.text.strip).to eq("Value 2")
    end
  end
end
