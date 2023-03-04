# frozen_string_literal: true

module AssessorInterface
  class QualificationRequestsReviewController < BaseController
    before_action :authorize_assessor

    def index
      @application_form = qualification_requests.first.application_form
      @assessment = @application_form.assessment
      @qualification_requests = qualification_requests

      render layout: "application"
    end

    def edit
      @application_form = qualification_request.application_form
      @assessment = qualification_request.assessment

      @form =
        RequestableReviewForm.new(
          requestable:,
          user: current_staff,
          reviewed: requestable.reviewed?,
          passed: requestable.passed,
          failure_assessor_note: requestable.failure_assessor_note,
        )
    end

    def update
      @application_form = qualification_request.application_form
      @assessment = qualification_request.assessment

      @form =
        RequestableReviewForm.new(
          requestable_review_form_params.merge(
            requestable:,
            user: current_staff,
          ),
        )

      if @form.save
        redirect_to [
                      :assessor_interface,
                      qualification_request.application_form,
                      qualification_request.assessment,
                      :qualification_requests_review,
                      :index,
                    ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def requestable_review_form_params
      params.require(:assessor_interface_requestable_review_form).permit(
        :reviewed,
        :passed,
        :failure_assessor_note,
      )
    end

    def qualification_requests
      @qualification_requests ||=
        QualificationRequest
          .joins(assessment: :application_form)
          .includes(:qualification)
          .where(
            assessment_id: params[:assessment_id],
            assessment: {
              application_form_id: params[:application_form_id],
            },
          )
          .order("qualifications.start_date": :desc)
    end

    def qualification_request
      @qualification_request ||= qualification_requests.find(params[:id])
    end

    alias_method :requestable, :qualification_request
  end
end
