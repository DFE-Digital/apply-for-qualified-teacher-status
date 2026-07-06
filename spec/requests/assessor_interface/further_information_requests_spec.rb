# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor Interface - Further Information Requests",
               type: :request do
  let(:signed_in_staff) { create(:staff, :with_assess_permission) }

  let(:application_form) do
    create(
      :application_form,
      :with_personal_information,
      :assessment_in_progress,
      :with_assessment,
    ).tap do |application_form|
      application_form.assessment.sections << create(
        :assessment_section,
        :qualifications,
        :failed,
        selected_failure_reasons: [
          build(
            :selected_failure_reason,
            key: "qualifications_dont_match_subjects",
            assessor_feedback: "A note.",
          ),
        ],
      )
    end
  end

  let(:assessment) { application_form.assessment }

  before { sign_in(signed_in_staff) }

  describe "POST /assessor/applications/:reference/assessments/:assessment_id/further-information-requests" do
    subject(:create_request) do
      post(
        "/assessor/applications/#{application_form.reference}" \
          "/assessments/#{assessment.id}/further-information-requests",
      )
    end

    context "when no request exists yet" do
      it "creates a further information request" do
        expect { create_request }.to change(
          assessment.further_information_requests,
          :count,
        ).by(1)
      end

      it "redirects to the application status page" do
        create_request
        expect(response).to redirect_to(
          "/assessor/applications/#{application_form.reference}/status",
        )
      end
    end

    context "when a request already exists (e.g. resubmitted via the back button)" do
      before { create(:further_information_request, assessment:) }

      it "does not create a second request" do
        expect { create_request }.not_to change(
          assessment.further_information_requests,
          :count,
        )
      end

      it "redirects to the application overview page rather than erroring" do
        create_request
        expect(response).to redirect_to(
          "/assessor/applications/#{application_form.reference}",
        )
      end

      it "sets a warning flash message" do
        create_request
        expect(flash[:warning]).to eq(
          "Further information has already been requested.",
        )
      end
    end
  end
end
