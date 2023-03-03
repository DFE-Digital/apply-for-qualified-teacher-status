# frozen_string_literal: true

module AssessorInterface
  class QualificationRequestsLocationController < BaseController
    before_action :authorize_note

    def index
      @application_form = qualification_requests.first.application_form
      @assessment = @application_form.assessment
      @qualification_requests = qualification_requests

      render layout: "application"
    end

    def edit
      @form =
        RequestableLocationForm.new(
          requestable:,
          user: current_staff,
          received: requestable.received?,
          location_note: requestable.location_note,
        )
    end

    def update
      @form =
        RequestableLocationForm.new(
          requestable_location_form.merge(requestable:, user: current_staff),
        )

      if @form.save
        redirect_to [
                      :assessor_interface,
                      qualification_request.application_form,
                    ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def requestable_location_form
      params.require(:assessor_interface_requestable_location_form).permit(
        :received,
        :location_note,
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
