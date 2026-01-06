# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationFormsExportContent do
  describe ".csv_headers" do
    subject(:csv_headers) { described_class.csv_headers }

    it "returns the headers for the CSV" do
      expect(subject).to eq(
        %w[
          reference
          country_trained_in
          region
          submitted_at
          assigned_to
          reviewer
          statuses
          stage
          prioritised
          awarded_at
          declined_at
          withdrawn_at
          trn
          suitability_flag
          referee_email_eligibility_concern
        ],
      )
    end
  end

  describe ".csv_row" do
    subject(:csv_row) { described_class.csv_row(application_form) }

    let(:application_form) do
      create :application_form, :submitted, :with_assessment, :with_work_history
    end

    it "returns the data for the application form" do
      expect(subject).to eq(
        [
          "\"#{application_form.reference}\"",
          CountryName.from_code(application_form.country.code),
          application_form.region.name,
          application_form.submitted_at.to_date,
          application_form.assessor&.name,
          application_form.reviewer&.name,
          "Assessment not started",
          "Not started",
          nil,
          nil,
          nil,
          nil,
          nil,
          false,
          false,
        ],
      )
    end

    context "when application form has multiple statuses and is prioritised" do
      let(:application_form) do
        create :application_form,
               :submitted,
               :with_assessment,
               :verification_stage,
               statuses: %i[overdue_reference overdue_lops]
      end

      before { application_form.assessment.update!(prioritised: true) }

      it "returns the data for the application form" do
        expect(subject).to eq(
          [
            "\"#{application_form.reference}\"",
            CountryName.from_code(application_form.country.code),
            application_form.region.name,
            application_form.submitted_at.to_date,
            application_form.assessor&.name,
            application_form.reviewer&.name,
            "Overdue reference, Overdue LoPS",
            "Verification",
            true,
            nil,
            nil,
            nil,
            nil,
            false,
            false,
          ],
        )
      end
    end

    context "when the application form has suitability flag" do
      before do
        create :suitability_record,
               emails:
                 create_list(
                   :suitability_record_email,
                   1,
                   value: application_form.teacher.email,
                 )
      end

      it "returns the data for the application form" do
        expect(subject).to eq(
          [
            "\"#{application_form.reference}\"",
            CountryName.from_code(application_form.country.code),
            application_form.region.name,
            application_form.submitted_at.to_date,
            application_form.assessor&.name,
            application_form.reviewer&.name,
            "Assessment not started",
            "Not started",
            nil,
            nil,
            nil,
            nil,
            nil,
            true,
            false,
          ],
        )
      end
    end

    context "when the application form has eligibility email concern" do
      let(:eligibility_domain) { create :eligibility_domain }

      before do
        application_form.work_histories.first.update!(eligibility_domain:)
      end

      it "returns the data for the application form" do
        expect(subject).to eq(
          [
            "\"#{application_form.reference}\"",
            CountryName.from_code(application_form.country.code),
            application_form.region.name,
            application_form.submitted_at.to_date,
            application_form.assessor&.name,
            application_form.reviewer&.name,
            "Assessment not started",
            "Not started",
            nil,
            nil,
            nil,
            nil,
            nil,
            false,
            true,
          ],
        )
      end
    end
  end
end
