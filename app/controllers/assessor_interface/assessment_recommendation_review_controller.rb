# frozen_string_literal: true

module AssessorInterface
  class AssessmentRecommendationReviewController < BaseController
    before_action :ensure_can_review
    before_action :load_assessment_and_application_form

    before_action only: %i[show edit update] do
      authorize %i[assessor_interface assessment_recommendation]
    end

    def show
      redirect_to [
                    :edit,
                    :assessor_interface,
                    application_form,
                    assessment,
                    :assessment_recommendation_review,
                  ]
    end

    def edit
      @professional_standing_request =
        assessment.professional_standing_request if assessment.professional_standing_request&.verify_failed?

      @qualification_requests =
        assessment
          .qualification_requests
          .includes(:qualification)
          .where(verify_passed: false)

      @reference_requests =
        assessment
          .reference_requests
          .includes(:work_history)
          .where(verify_passed: false)
          .order_by_role

      render layout: "full_from_desktop"
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
          .where(
            application_form: {
              reference: params[:application_form_reference],
            },
          )
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
