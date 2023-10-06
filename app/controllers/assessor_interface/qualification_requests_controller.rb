# frozen_string_literal: true

module AssessorInterface
  class QualificationRequestsController < BaseController
    before_action :authorize_assessor
    before_action :set_variables, except: :index

    def index
      @qualification_requests = qualification_requests
      @application_form = qualification_requests.first.application_form
      @assessment = @application_form.assessment

      render layout: "application"
    end

    def edit
      received =
        if requestable.received?
          true
        elsif requestable.expired?
          false
        end

      passed = (requestable.review_passed? if requestable.received?)
      failed = (requestable.review_failed? if requestable.expired?)

      @form =
        QualificationRequestForm.new(
          requestable:,
          user: current_staff,
          received:,
          passed:,
          note: requestable.review_note,
          failed:,
        )
    end

    def update
      @form =
        QualificationRequestForm.new(
          form_params.merge(requestable:, user: current_staff),
        )

      if @form.save
        redirect_to [
                      :assessor_interface,
                      qualification_request.application_form,
                      qualification_request.assessment,
                      :qualification_requests,
                    ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_variables
      @qualification_request = qualification_request
      @application_form = qualification_request.application_form
      @assessment = qualification_request.assessment
    end

    def form_params
      params.require(:assessor_interface_qualification_request_form).permit(
        :received,
        :passed,
        :note,
        :failed,
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
