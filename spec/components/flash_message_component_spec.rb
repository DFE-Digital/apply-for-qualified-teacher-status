# frozen_string_literal: true

require "rails_helper"

RSpec.describe FlashMessage::Component, type: :component do
  subject(:component) { render_inline(described_class.new(flash:)) }

  let(:flash) { {} }

  it "does not render any content when flash is not set" do
    expect(component.text).to be_empty
  end

  context "when an invalid flash key is provided" do
    let(:flash) { { invalid: "Message" } }

    it "does not render any content" do
      expect(component.text).to be_empty
    end
  end

  context "when a valid flash key is provided" do
    let(:flash) { { success: "Your application has been updated" } }

    it "renders the correct content" do
      expect(
        component.css(".govuk-notification-banner__heading").text,
      ).to include("Your application has been updated")
    end
  end

  context "when a Devise flash key is provided" do
    let(:flash) { { alert: "Your application has been updated" } }

    it "renders the correct content" do
      expect(
        component.css(".govuk-notification-banner__heading").text,
      ).to include("Your application has been updated")
    end
  end

  context "when an info flash key is provided" do
    let(:flash) { { info: "This service will be unavailable tomorrow" } }

    it "renders a region role" do
      expect(
        component.css(".govuk-notification-banner").attribute("role").value,
      ).to eq("region")
    end
  end

  context "when a success flash key is provided" do
    let(:flash) { { success: "Your application has been updated" } }

    it "renders an alert role" do
      expect(
        component.css(".govuk-notification-banner").attribute("role").value,
      ).to eq("alert")
    end
  end

  context "when a warning flash key is provided" do
    let(:flash) { { warning: "There is a problem" } }

    it "renders an alert role" do
      expect(
        component.css(".govuk-notification-banner").attribute("role").value,
      ).to eq("alert")
    end
  end

  context "when a secondary message is provided" do
    let(:flash) { { info: ["Message", "Some more details..."] } }

    it "renders the correct content" do
      expect(component.text).to include("Message")
      expect(component.text).to include("Some more details...")
    end
  end
end
