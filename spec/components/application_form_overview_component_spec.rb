# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationFormOverview::Component, type: :component do
  subject(:component) do
    render_inline(described_class.new(application_form, current_staff:))
  end

  let(:application_form) { create(:application_form, :submitted) }
  let(:current_staff) { create(:staff) }

  describe "heading" do
    subject(:text) { component.at_css("h2").text.strip }

    it { is_expected.to eq("Overview") }
  end

  describe "summary list" do
    subject(:dl) { component.at_css("dl") }

    it { is_expected.not_to be_nil }

    describe "text" do
      subject(:text) { dl.text.strip }

      it { is_expected.to include("Name") }
      it { is_expected.to include("Country trained in") }
      it { is_expected.to include("State/territory trained in") }
      it { is_expected.to include("Created on") }
      it { is_expected.to include("Working days since submission") }
      it { is_expected.to include("Assigned to") }
      it { is_expected.to include("Reviewer") }
      it { is_expected.to include("Reference") }
      it { is_expected.to include("Status") }
    end
  end
end
