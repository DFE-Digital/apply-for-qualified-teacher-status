# frozen_string_literal: true

require "rails_helper"

RSpec.describe DestroyApplicationForm do
  before do
    2.times do
      application_form =
        create(:application_form, :submitted, :with_identification_document)

      create(:qualification, application_form:)
      create(:work_history, application_form:)
      create(:note, application_form:)

      assessment =
        create(
          :assessment,
          :with_further_information_request,
          application_form:,
        )
      create(:assessment_section, :personal_information, assessment:)
    end
  end

  subject(:call) do
    described_class.call(application_form: ApplicationForm.first)
  end

  shared_examples "deletes model" do |model, from, to|
    it "deletes all #{model}" do
      expect { call }.to change(model, :count).from(from || 2).to(to || 1)
    end
  end

  include_examples "deletes model", ApplicationForm
  include_examples "deletes model", Assessment
  include_examples "deletes model", AssessmentSection
  include_examples "deletes model", Document, 12, 6
  include_examples "deletes model", FurtherInformationRequest
  include_examples "deletes model", FurtherInformationRequestItem, 4, 2
  include_examples "deletes model", Note
  include_examples "deletes model", Qualification
  include_examples "deletes model", Teacher
  include_examples "deletes model", TimelineEvent
  include_examples "deletes model", Upload
  include_examples "deletes model", WorkHistory
end
