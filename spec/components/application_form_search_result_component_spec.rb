# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationFormSearchResult::Component, type: :component do
  subject(:component) { render_inline(described_class.new(application_form:)) }

  let(:application_form) do
    create(
      :application_form,
      :submitted,
      :with_reviewer,
      given_names: "Given",
      family_name: "Family",
    )
  end

  describe "heading text" do
    subject(:text) { component.at_css("h2").text.strip }

    it { is_expected.to eq("Given Family") }
  end

  describe "heading link" do
    subject(:href) { component.at_css("h2 > a")["href"] }

    it { is_expected.to eq("/assessor/applications/#{application_form.id}") }
  end

  describe "description list" do
    subject(:dl) { component.at_css("dl") }

    it { is_expected.to_not be_nil }

    describe "text" do
      subject(:text) { dl.text.strip }

      it { is_expected.to include("Country trained in") }
      it { is_expected.to include("Email") }
      it { is_expected.to include("State/territory trained in") }
      it { is_expected.to include("Created on") }
      it { is_expected.to include("Working days since submission") }
      it { is_expected.to include("Assigned to") }
      it { is_expected.to include("Reviewer") }
      it { is_expected.to include("Status") }
      it { is_expected.to include("Reference") }

      context "where there is no reviewer assigned" do
        before { application_form.update(reviewer: nil) }

        it { is_expected.not_to include("Reviewer") }
      end
    end
  end
end
