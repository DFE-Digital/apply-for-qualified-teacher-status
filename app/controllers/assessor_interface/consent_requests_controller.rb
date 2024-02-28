# frozen_string_literal: true

module AssessorInterface
  class ConsentRequestsController < BaseController
    include HistoryTrackable

    before_action :set_variables

    def edit_review
      @form = RequestableReviewForm.new(requestable:)
    end

    def update_review
      @form =
        RequestableReviewForm.new(
          requestable:,
          user: current_staff,
          **review_form_params,
        )

      if @form.save
        redirect_to [:review, :assessor_interface, application_form, assessment]
      else
        render :edit_review, status: :unprocessable_entity
      end
    end

    private

    def application_form
      @application_form ||=
        ApplicationForm.includes(:assessment).find_by(
          reference: params[:application_form_reference],
          assessment: {
            id: params[:assessment_id],
          },
        )
    end

    def assessment
      @assessment ||= application_form.assessment
    end

    def consent_requests
      @consent_requests ||= assessment.consent_requests
    end

    def consent_request
      @consent_request ||= consent_requests.find(params[:id])
    end

    alias_method :requestable, :consent_request

    def set_variables
      @consent_request = authorize [:assessor_interface, consent_request]
      @application_form = application_form
      @assessment = assessment
    end

    def review_form_params
      params.require(:assessor_interface_requestable_review_form).permit(
        :passed,
        :note,
      )
    end
  end
end
