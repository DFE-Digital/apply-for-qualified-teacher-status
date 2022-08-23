require "rails_helper"

RSpec.describe "Teaching authority contact information", type: :view do
  before { render "shared/teaching_authority_contact_information", region: }

  subject { rendered }

  context "with a region with teaching authority" do
    let(:region) { create(:region, :with_teaching_authority) }

    it { is_expected.to_not include('<p class="govuk-body">or</p>') }
    it { is_expected.to include(region.teaching_authority_address) }
  end

  context "with a country with teaching authority" do
    let(:country) { create(:country, :with_teaching_authority) }
    let(:region) { create(:region, country:) }

    it { is_expected.to_not include('<p class="govuk-body">or</p>') }
    it { is_expected.to include(country.teaching_authority_address) }
  end

  context "with a country and a region with teaching authority" do
    let(:country) { create(:country, :with_teaching_authority) }
    let(:region) { create(:region, :with_teaching_authority, country:) }

    it { is_expected.to include('<p class="govuk-body">or</p>') }
    it { is_expected.to include(region.teaching_authority_address) }
    it { is_expected.to include(country.teaching_authority_address) }
  end

  context "with a region with teaching authority other" do
    let(:region) { create(:region, teaching_authority_other: "Other") }

    it { is_expected.to match(/Other/) }
  end

  context "with a country with teaching authority other" do
    let(:region) do
      create(
        :region,
        country: create(:country, teaching_authority_other: "Other")
      )
    end

    it { is_expected.to match(/Other/) }
  end
end
