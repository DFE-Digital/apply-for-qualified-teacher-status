# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationFormSearchResult::Component, type: :component do
  subject(:component) do
    render_inline(described_class.new(application_form:, search_params:))
  end

  let(:application_form) do
    create(
      :application_form,
      :submitted,
      given_names: "Given",
      family_name: "Family",
    )
  end

  let(:search_params) { {} }

  describe "heading text" do
    subject(:text) { component.at_css("h2").text.strip }

    it { is_expected.to eq("Given Family") }
  end

  describe "heading link" do
    subject(:href) { component.at_css("h2 > a")["href"] }

    it { is_expected.to eq("/assessor/applications/#{application_form.id}") }

    context "with search params" do
      let(:search_params) { { states: %w[awarded] } }

      it do
        is_expected.to eq(
          "/assessor/applications/#{application_form.id}?search%5Bstates%5D%5B%5D=awarded",
        )
      end
    end
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
      it { is_expected.to include("Days remaining in SLA") }
      it { is_expected.to include("Assigned to") }
      it { is_expected.to include("Reviewer") }
      it { is_expected.to include("Status") }
      it { is_expected.to include("Notes") }
    end
  end
end
