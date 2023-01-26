# frozen_string_literal: true

module AssessorInterface
  class ProfessionalStandingRequestsController < BaseController
    before_action :authorize_note

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
        redirect_to [:assessor_interface, application_form]
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

    def application_form
      @application_form ||=
        ApplicationForm.includes(
          assessment: :professional_standing_request,
        ).find(params[:application_form_id])
    end

    delegate :professional_standing_request, to: :assessment
    delegate :assessment, to: :application_form

    alias_method :requestable, :professional_standing_request
  end
end
