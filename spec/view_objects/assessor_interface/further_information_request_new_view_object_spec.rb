# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::FurtherInformationRequestNewViewObject do
  subject(:view_object) do
    described_class.new(params: ActionController::Parameters.new(params))
  end

  let(:application_form) { create(:application_form, :submitted) }
  let(:assessment) { create(:assessment, application_form:) }
  let(:params) do
    {
      assessment_id: assessment.id,
      application_form_reference: application_form.reference,
    }
  end

  describe "#grouped_review_items_by_assessment_section" do
    subject(:grouped_review_items_by_assessment_section) do
      view_object.grouped_review_items_by_assessment_section
    end

    let(:personal_information_assessment_section) do
      create :assessment_section, :personal_information, assessment:
    end

    let(:qualifications_assessment_section) do
      create :assessment_section, :qualifications, assessment:
    end

    before do
      create :selected_failure_reason,
             assessment_section: personal_information_assessment_section,
             key: "passport_document_illegible"
      create :selected_failure_reason,
             assessment_section: personal_information_assessment_section,
             key: "passport_document_mismatch"

      create :selected_failure_reason,
             assessment_section: qualifications_assessment_section,
             key: "qualifications_dont_match_other_details"
      create :selected_failure_reason,
             assessment_section: qualifications_assessment_section,
             key: "qualifications_or_modules_required_not_provided"
    end

    it do
      expect(subject).to eq(
        [
          {
            heading: "Personal information",
            items: [
              {
                heading:
                  "There is a problem with the passport. For example, " \
                    "it’s incorrect, illegible, or incomplete.",
                feedback: "We need more information.",
              },
              {
                heading:
                  "The name on the application form is different from the passport, " \
                    "but no evidence of change of name was provided.",
                feedback: "We need more information.",
              },
            ],
          },
          {
            heading: "Qualifications",
            items: [
              {
                heading:
                  "Uploaded qualifications do not match other information entered, " \
                    "for example, the subject, name of qualification, name of institution or dates.",
                feedback: "We need more information.",
              },
              {
                heading:
                  "The applicant has not provided the required qualifications or modules.",
                feedback: "We need more information.",
              },
            ],
          },
        ],
      )
    end
  end
end
