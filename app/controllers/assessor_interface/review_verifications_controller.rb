# frozen_string_literal: true

module AssessorInterface
  class ReviewVerificationsController < BaseController
    include RegionHelper
    before_action :authorize_assessor

    def index
      @application_form = assessment.application_form
      @assessment = assessment

      @professional_standing_request =
        assessment.professional_standing_request if assessment.professional_standing_request.verify_failed?

      render layout: "full_from_desktop"
    end

    private

    def assessment
      @assessment ||=
        Assessment
          .includes(:application_form)
          .where(application_form_id: params[:application_form_id])
          .find(params[:assessment_id])
    end
  end
end
