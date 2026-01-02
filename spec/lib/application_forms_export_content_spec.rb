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
          submitted_at
          assigned_to
          reviewer
          given_names
          family_name
          alternative_given_names
          alternative_family_name
          date_of_birth
          statuses
          stage
          prioritised
          awarded_at
          declined_at
          withdrawn_at
        ],
      )
    end
  end

  describe ".csv_row" do
    subject(:csv_row) { described_class.csv_row(application_form) }

    let(:application_form) do
      create :application_form, :submitted, :with_assessment
    end

    it "returns the data for the application form" do
      expect(subject).to eq(
        [
          "\"#{application_form.reference}\"",
          CountryName.from_code(application_form.country.code),
          application_form.submitted_at.to_date,
          application_form.assessor&.name,
          application_form.reviewer&.name,
          application_form.given_names,
          application_form.family_name,
          application_form.alternative_given_names,
          application_form.alternative_family_name,
          application_form.date_of_birth,
          "Assessment not started",
          "Not started",
          nil,
          nil,
          nil,
          nil,
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
            application_form.submitted_at.to_date,
            application_form.assessor&.name,
            application_form.reviewer&.name,
            application_form.given_names,
            application_form.family_name,
            application_form.alternative_given_names,
            application_form.alternative_family_name,
            application_form.date_of_birth,
            "Overdue reference, Overdue LoPS",
            "Verification",
            true,
            nil,
            nil,
            nil,
          ],
        )
      end
    end
  end
end
