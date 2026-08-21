# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::SLA::CountryGroupings do
  subject(:filtered_scope) { described_class.apply(scope:, params:) }

  let(:scope) { ApplicationForm.all }

  context "when no country groupings are given" do
    context "with key absent" do
      let(:params) { {} }

      it { is_expected.to eq(scope) }
    end

    context "with empty grouping" do
      let(:params) { { country_groupings: [""] } }

      it { is_expected.to eq(scope) }
    end
  end

  context "when filtering by country grouping" do
    let(:scope) { ApplicationForm.all }

    let!(:uk) { application_form_in(Country::CODES_IN_UK.first) }
    let!(:gibraltar) { application_form_in(Country::GIBRALTAR_CODE) }
    let!(:eu) { application_form_in(Country::CODES_IN_EU.first) }
    let!(:efta) { application_form_in(Country::CODES_IN_EFTA.first) }
    let!(:rest_of_world) do
      application_form_in(Country::CODES_IN_REST_OF_WORLD.first)
    end

    context "with uk_and_gibraltar" do
      let(:params) { { country_groupings: %w[uk_and_gibraltar] } }

      it { is_expected.to contain_exactly(uk, gibraltar) }
    end

    context "with eu" do
      let(:params) { { country_groupings: %w[eu] } }

      it { is_expected.to contain_exactly(eu) }
    end

    context "with efta" do
      let(:params) { { country_groupings: %w[efta] } }

      it { is_expected.to contain_exactly(efta) }
    end

    context "with rest_of_world" do
      let(:params) { { country_groupings: %w[rest_of_world] } }

      it { is_expected.to contain_exactly(rest_of_world) }
    end

    context "with multiple groupings" do
      let(:params) { { country_groupings: %w[eu efta] } }

      it { is_expected.to contain_exactly(eu, efta) }
    end
  end

  def application_form_in(code)
    create(
      :application_form,
      region: create(:region, country: create(:country, code:)),
    )
  end
end
