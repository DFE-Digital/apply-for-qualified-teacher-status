# frozen_string_literal: true

module AssessorInterface
  class ProfessionalStandingRequestsController < BaseController
    before_action :authorize_note

    def edit
      @professional_standing_request_form =
        ProfessionalStandingRequestForm.new(
          professional_standing_request:,
          user: current_staff,
          received: professional_standing_request.received?,
          location_note: professional_standing_request.location_note,
        )
    end

    def update
      @professional_standing_request_form =
        ProfessionalStandingRequestForm.new(
          professional_standing_request_form.merge(
            professional_standing_request:,
            user: current_staff,
          ),
        )

      if @professional_standing_request_form.save
        redirect_to [:assessor_interface, application_form]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def professional_standing_request_form
      params.require(
        :assessor_interface_professional_standing_request_form,
      ).permit(:received, :location_note)
    end

    def application_form
      @application_form ||=
        ApplicationForm.includes(
          assessment: :professional_standing_request,
        ).find(params[:application_form_id])
    end

    delegate :professional_standing_request, to: :assessment
    delegate :assessment, to: :application_form
  end
end
