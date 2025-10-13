# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationFormSearchResult::Component, type: :component do
  subject(:component) do
    render_inline(
      described_class.new(
        application_form,
        current_staff:,
        unsuitable:,
        prioritised:,
        on_hold:,
      ),
    )
  end

  let(:unsuitable) { false }
  let(:prioritised) { false }
  let(:on_hold) { false }

  let(:application_form) do
    create(
      :application_form,
      :submitted,
      given_names: "Given",
      family_name: "Family",
      reviewer: create(:staff),
    )
  end
  let(:current_staff) { create(:staff) }

  describe "heading text" do
    subject(:text) { component.at_css("h2").text.strip }

    it { is_expected.to eq("Given Family") }
  end

  describe "heading link" do
    subject(:href) { component.at_css("h2 > a")["href"] }

    it do
      expect(subject).to eq(
        "/assessor/applications/#{application_form.reference}",
      )
    end
  end

  describe "heading flags" do
    subject(:flag) { component.at_css("h2 .govuk-tag").text }

    context "when unsuitable true" do
      let(:unsuitable) { true }

      it { expect(subject).to eq("Flagged for suitability") }
    end

    context "when prioritised true" do
      let(:prioritised) { true }

      it { expect(subject).to eq("Prioritised") }
    end

    context "when on_hold true" do
      let(:on_hold) { true }

      it { expect(subject).to eq("On hold") }
    end
  end

  describe "description list" do
    subject(:dl) { component.at_css("dl") }

    it { is_expected.not_to be_nil }

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
        before { application_form.update!(reviewer: nil) }

        it { is_expected.not_to include("Reviewer") }
      end
    end
  end
end
