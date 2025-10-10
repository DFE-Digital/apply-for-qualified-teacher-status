# frozen_string_literal: true

module AssessorInterface
  class ApplicationHoldsController < BaseController
    before_action { authorize %i[assessor_interface note] }

    def new
      @form = CreateApplicationHoldForm.new(application_form:)
    end

    def new_confirm
      @form = CreateApplicationHoldForm.new(
        application_form:,
        reason:,
        reason_comment:,
      )
    end

    def create
      @form =
        CreateApplicationHoldForm.new(
          form_params.merge(application_form:, user: current_staff),
        )

      if @form.save
        redirect_to [:confirmation, :assessor_interface, application_form, :application_holds, application_form.active_application_hold]
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def application_form
      @application_form ||=
        ApplicationForm.find_by!(reference: params[:application_form_reference])
    end

    def form_params
      params.require(:assessor_interface_create_note_form).permit(:text)
    end
  end
end
