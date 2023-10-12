# frozen_string_literal: true

module AssessorInterface
  class AssessmentRecommendationReviewController < BaseController
    before_action :authorize_assessor
    before_action :ensure_can_review
    before_action :load_assessment_and_application_form

    def edit
      @professional_standing_request =
        assessment.professional_standing_request if assessment.professional_standing_request.verify_failed?
    end

    def update
      ActiveRecord::Base.transaction do
        assessment.review!
        ApplicationFormStatusUpdater.call(
          application_form:,
          user: current_staff,
        )
      end

      redirect_to [:status, :assessor_interface, application_form]
    end

    private

    def assessment
      @assessment ||=
        Assessment
          .includes(:application_form)
          .where(application_form_id: params[:application_form_id])
          .find(params[:assessment_id])
    end

    delegate :application_form, to: :assessment

    def ensure_can_review
      unless assessment.can_review?
        redirect_to [:assessor_interface, application_form]
      end
    end

    def load_assessment_and_application_form
      @assessment = assessment
      @application_form = application_form
    end
  end
end