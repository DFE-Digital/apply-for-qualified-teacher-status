# frozen_string_literal: true

module AssessorInterface
  class ReferenceRequestsController < BaseController
    before_action :authorize_note

    def edit
      @form = RequestableForm.new(requestable: reference_request)
    end

    def update
      @form =
        RequestableForm.new(
          requestable: reference_request,
          user: current_staff,
          **reference_request_form_params,
        )

      if @form.save
        redirect_to [
                      :assessor_interface,
                      assessment.application_form,
                      assessment,
                      :verify_references,
                    ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def reference_request_form_params
      params.fetch(:assessor_interface_requestable_form, {}).permit(:passed)
    end

    def reference_request
      @reference_request ||=
        ReferenceRequest
          .includes(:work_history, assessment: :application_form)
          .where(
            assessment_id: params[:assessment_id],
            assessment: {
              application_form_id: params[:application_form_id],
            },
          )
          .find(params[:id])
    end

    delegate :assessment, to: :reference_request
  end
end
