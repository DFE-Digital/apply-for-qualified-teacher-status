# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor Interface - Assessment Recommendation Award",
               type: :request do
  let(:signed_in_staff) { create(:staff, :with_assess_permission) }

  let(:application_form) do
    create(
      :application_form,
      :assessment_in_progress,
      :with_personal_information,
    )
  end

  let(:enough_duration_work_history) do
    create(
      :work_history,
      application_form:,
      start_date: Date.new(2020, 1, 1),
      end_date: Date.new(2021, 12, 31),
      hours_per_week: 30,
    )
  end

  before { sign_in(signed_in_staff) }

  describe "GET /assessor/applications/:reference/assessments/:assessment_id/recommendation/award/edit" do
    subject(:get_edit) do
      get(
        "/assessor/applications/#{application_form.reference}" \
          "/assessments/#{assessment.id}/recommendation/award/edit",
      )
    end

    context "when the assessment is in review with a failed reference request" do
      let(:assessment) do
        create(
          :assessment,
          :review,
          application_form:,
          induction_required: false,
        )
      end

      before do
        create(
          :received_reference_request,
          :review_failed,
          assessment:,
          work_history: create(:work_history, application_form:),
        )
        create(
          :received_reference_request,
          :review_passed,
          assessment:,
          work_history: enough_duration_work_history,
        )
      end

      it "shows the invalid references important note" do
        get_edit

        expect(response.body).to include(
          "Important notes before you confirm QTS",
        )
        expect(response.body).to include(
          "This application has one or more invalid references.",
        )
      end
    end

    context "when the assessment is in verify with a reference request that failed review but passed verify" do
      let(:assessment) do
        create(
          :assessment,
          :verify,
          application_form:,
          induction_required: false,
        )
      end

      before do
        create(
          :received_reference_request,
          :review_failed,
          :verify_passed,
          assessment:,
          work_history: enough_duration_work_history,
        )
      end

      it "does not show the invalid references important note" do
        get_edit

        expect(response.body).not_to include(
          "Important notes before you confirm QTS",
        )
        expect(response.body).not_to include(
          "This application has one or more invalid references.",
        )
      end
    end
  end
end
