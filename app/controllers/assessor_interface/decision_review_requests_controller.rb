# frozen_string_literal: true

module AssessorInterface
  class DecisionReviewRequestsController < BaseController
    def edit
      @application_form = assessment.application_form
      @form =
        DecisionReviewRequestReviewForm.new(
          decision_review_request:,
          review_passed: decision_review_request.review_passed,
          review_note: decision_review_request.review_note,
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
        render :edit_confirm
      end
    end

    def confirmation
      @application_form = assessment.application_form

      decision_review_request
    end

    private

    def decision_review_request_review_form_params
      params.require(
        :assessor_interface_decision_review_request_review_form,
      ).permit(:review_passed, :review_note)
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
        authorize [:assessor_interface, assessment.decision_review_request]
    end
  end
end
