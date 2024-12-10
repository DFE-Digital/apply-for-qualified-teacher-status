# frozen_string_literal: true

require "rails_helper"

RSpec.describe DestroyApplicationForm do
  subject(:call) do
    described_class.call(application_form: ApplicationForm.first)
  end

  before do
    2.times do
      application_form =
        create(
          :application_form,
          :submitted,
          :with_identification_document,
          :with_teaching_qualification,
          :with_work_history,
        )

      create(:timeline_event, :stage_changed, application_form:)
      create(:note, application_form:)
      create(:dqt_trn_request, application_form:)
      create(:trs_trn_request, application_form:)

      assessment =
        create(
          :assessment,
          :with_consent_requests,
          :with_further_information_request,
          :with_professional_standing_request,
          :with_qualification_requests,
          :with_reference_requests,
          application_form:,
        )

      assessment_section =
        create(:assessment_section, :personal_information, assessment:)

      create(:selected_failure_reason, assessment_section:)
    end
  end

  shared_examples "deletes model" do |model, from, to|
    it "deletes all #{model}" do
      expect { call }.to change(model, :count).from(from || 2).to(to || 1)
    end
  end

  include_examples "deletes model", ApplicationForm
  include_examples "deletes model", Assessment
  include_examples "deletes model", AssessmentSection
  include_examples "deletes model", ConsentRequest
  include_examples "deletes model", DQTTRNRequest
  include_examples "deletes model", TRSTRNRequest
  include_examples "deletes model", Document, 20, 10
  include_examples "deletes model", FurtherInformationRequest
  include_examples "deletes model", FurtherInformationRequestItem, 6, 3
  include_examples "deletes model", Note
  include_examples "deletes model", ProfessionalStandingRequest
  include_examples "deletes model", Qualification
  include_examples "deletes model", QualificationRequest
  include_examples "deletes model", ReferenceRequest, 4, 2
  include_examples "deletes model", SelectedFailureReason
  include_examples "deletes model", Teacher
  include_examples "deletes model", TimelineEvent
  include_examples "deletes model", Upload, 6, 3
  include_examples "deletes model", WorkHistory, 4, 2
end
