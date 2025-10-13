# frozen_string_literal: true

module AssessorInterface
  class ApplicationHoldsController < BaseController
    before_action { authorize %i[assessor_interface application_hold] }

    before_action :ensure_application_not_already_on_hold,
                  only: %i[new new_submit new_confirm create]

    def new
      @form = CreateApplicationHoldForm.new(application_form:)
    end

    def new_submit
      @form =
        CreateApplicationHoldForm.new(
          form_params.merge!(application_form:, user: current_staff),
        )

      if @form.valid?
        session[:"application_hold_#{application_form.reference}"] = @form

        redirect_to [
                      :new_confirm,
                      :assessor_interface,
                      application_form,
                      :application_holds,
                    ]
      else
        render :new, status: :unprocessable_entity
      end
    end

    def new_confirm
      @form = session[:"application_hold_#{application_form.reference}"]
    end

    def create
      @form =
        CreateApplicationHoldForm.new(
          form_params.merge(application_form:, user: current_staff),
        )

      if @form.save
        redirect_to confirmation_assessor_interface_application_form_application_hold_path(
                      application_form,
                      application_form.reload.active_application_hold,
                    )
      else
        render :new, status: :unprocessable_entity
      end
    end

    def confirmation
      application_form
    end

    private

    def application_form
      @application_form ||=
        ApplicationForm.find_by!(reference: params[:application_form_reference])
    end

    def form_params
      params.require(:assessor_interface_create_application_hold_form).permit(
        :reason,
        :reason_comment,
      )
    end

    def ensure_application_not_already_on_hold
      if application_form.on_hold?
        flash[:alert] = "Application is already on hold"

        redirect_to assessor_interface_application_form_path(application_form)
      end
    end
  end
end
