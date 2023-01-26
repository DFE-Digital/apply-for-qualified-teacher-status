# frozen_string_literal: true

module AssessorInterface
  class QualificationRequestsController < BaseController
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

    def qualification_request
      @qualification_request ||=
        QualificationRequest
          .includes(assessment: :application_form)
          .where(
            assessment_id: params[:assessment_id],
            assessment: {
              application_form_id: params[:application_form_id],
            },
          )
          .find(params[:id])
    end

    delegate :application_form, :assessment, to: :qualification_request

    alias_method :requestable, :qualification_request
  end
end
