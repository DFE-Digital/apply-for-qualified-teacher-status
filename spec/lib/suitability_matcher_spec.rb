# frozen_string_literal: true

require "rails_helper"

RSpec.describe SuitabilityMatcher do
  subject(:call) { described_class.call(application_form:) }

  let(:application_form) do
    create(:application_form, :with_personal_information)
  end

  it { is_expected.to be false }

  context "with an existing declined application form" do
    let!(:other_application_form) do
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

    context "when declined due to suitability" do
      before do
        assessment_section =
          create(
            :assessment_section,
            assessment: other_application_form.assessment,
          )
        create(
          :selected_failure_reason,
          key: FailureReasons::SUITABILITY,
          assessment_section:,
        )
      end

      it { is_expected.to be true }
    end
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
