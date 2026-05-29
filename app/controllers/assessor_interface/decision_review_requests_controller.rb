# frozen_string_literal: true

module AssessorInterface
  class DecisionReviewRequestsController < BaseController
    before_action :ensure_not_already_reviewed,
                  only: %i[update edit_confirm update_confirm]

    def edit
      @application_form = assessment.application_form
      @form =
        DecisionReviewRequestReviewForm.new(
          decision_review_request:,
          review_passed: decision_review_request.review_passed,
          review_passed_note:
            if decision_review_request.review_passed
              decision_review_request.review_note
            end,
          review_failed_note:
            unless decision_review_request.review_passed
              decision_review_request.review_note
            end,
        )
    end

    def update
      @application_form = assessment.application_form
      @form =
        DecisionReviewRequestReviewForm.new(
          decision_review_request:,
          **decision_review_request_review_form_params,
        )

      if @form.save
        redirect_to [
                      :assessor_interface,
                      @application_form,
                      assessment,
                      decision_review_request,
                      :confirm,
                    ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def edit_confirm
      @application_form = assessment.application_form

      @form =
        RequestableReviewForm.new(
          requestable: decision_review_request,
          passed: decision_review_request.review_passed,
          note: decision_review_request.review_note,
        )
    end

    def update_confirm
      @application_form = assessment.application_form
      @form =
        RequestableReviewForm.new(
          requestable: decision_review_request,
          passed: decision_review_request.review_passed,
          note: decision_review_request.review_note,
          user: current_staff,
        )

      if @form.save
        redirect_to [
                      :assessor_interface,
                      @application_form,
                      assessment,
                      decision_review_request,
                      :confirmation,
                    ]
      else
        render :edit_confirm, status: :unprocessable_entity
      end
    rescue RollbackAssessment::InvalidState => e
      flash[:warning] = e.message
      render :edit_confirm, status: :unprocessable_entity
    end

    def confirmation
      @application_form = assessment.application_form

      decision_review_request
    end

    private

    def decision_review_request_review_form_params
      params.require(
        :assessor_interface_decision_review_request_review_form,
      ).permit(:review_passed, :review_passed_note, :review_failed_note)
    end

    def ensure_not_already_reviewed
      if decision_review_request.reviewed_at.present?
        @application_form = assessment.application_form

        redirect_to [
                      :edit,
                      :assessor_interface,
                      @application_form,
                      assessment,
                      decision_review_request,
                    ]
      end
    end

    def assessment
      @assessment ||=
        Assessment.joins(:application_form).find_by(
          id: params[:assessment_id],
          application_form: {
            reference: params[:application_form_reference],
          },
        )
    end

    def decision_review_request
      @decision_review_request ||=
        authorize [
                    :assessor_interface,
                    assessment.decision_review_requests.find(
                      params[:id] || params[:decision_review_request_id],
                    ),
                  ]
    end
  end
end
