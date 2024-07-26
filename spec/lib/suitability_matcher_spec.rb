# frozen_string_literal: true

require "rails_helper"

RSpec.describe SuitabilityMatcher do
  subject(:suitability_matcher) { described_class.new }

  let(:application_form) do
    create(:application_form, :with_personal_information)
  end

  describe "#flag_as_unsuitable?" do
    subject(:flag_as_unsuitable?) do
      suitability_matcher.flag_as_unsuitable?(application_form:)
    end

    it { is_expected.to be false }

    context "with an existing declined application form" do
      before do
        create(
          :application_form,
          :with_assessment,
          given_names: application_form.given_names,
          family_name: application_form.family_name,
          date_of_birth: application_form.date_of_birth,
          region: application_form.region,
        )
      end

      it { is_expected.to be false }
    end

    context "with a suitability record" do
      let!(:suitability_record) { create(:suitability_record) }

      it { is_expected.to be false }

      context "when the record matches" do
        before do
          suitability_record.update!(
            date_of_birth: application_form.date_of_birth,
            country_code: application_form.country.code,
          )
          create(
            :suitability_record_name,
            suitability_record:,
            value:
              "#{application_form.given_names} #{application_form.family_name}",
          )
        end

        it { is_expected.to be true }
      end
    end
  end
end
