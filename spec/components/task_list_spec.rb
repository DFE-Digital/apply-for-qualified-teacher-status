# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskList::Component, type: :component do
  subject(:component) { render_inline(described_class.new(sections)) }

  let(:sections) do
    [
      {
        title: "Section A",
        items: [{ name: "Item A", href: "/item-a", status: "not_started" }],
      },
      { title: "Section B", items: [{ name: "Item B", status: "completed" }] },
    ]
  end

  it "numbers the section titles" do
    expect(component.text.squish).to include("1. Section A")
    expect(component.text.squish).to include("2. Section B")
  end

  it "shows the item statuses" do
    expect(component.text.squish).to include("Item A Not started")
    expect(component.text.squish).to include("Item B Completed")
  end
end
