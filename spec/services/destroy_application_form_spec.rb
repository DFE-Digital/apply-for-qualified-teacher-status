# frozen_string_literal: true

require "rails_helper"

RSpec.describe DestroyApplicationForm do
  let(:teacher) { create(:teacher) }

  let!(:application_form) do
    create(
      :application_form,
      :submitted,
      :with_identification_document,
      teacher:,
    )
  end

  before do
    create(:qualification, application_form:)
    create(:work_history, application_form:)
    create(:note, application_form:)

    assessment =
      create(:assessment, :with_further_information_request, application_form:)
    create(:assessment_section, :personal_information, assessment:)
  end

  subject(:call) { described_class.call(application_form:) }

  shared_examples "deletes model" do |model|
    it "deletes all #{model}" do
      expect { call }.to change(model, :count).to(0)
    end
  end

  include_examples "deletes model", ApplicationForm
  include_examples "deletes model", Assessment
  include_examples "deletes model", AssessmentSection
  include_examples "deletes model", Document
  include_examples "deletes model", FurtherInformationRequest
  include_examples "deletes model", FurtherInformationRequestItem
  include_examples "deletes model", Note
  include_examples "deletes model", Qualification
  include_examples "deletes model", Teacher
  include_examples "deletes model", TimelineEvent
  include_examples "deletes model", Upload
  include_examples "deletes model", WorkHistory
end
