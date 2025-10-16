# frozen_string_literal: true

module AssessorInterface
  class ApplicationHoldsController < BaseController
    before_action { authorize %i[assessor_interface application_hold] }

    before_action :ensure_application_not_completed
    before_action :ensure_application_not_already_on_hold,
                  only: %i[new new_submit new_confirm create]
    before_action :ensure_application_not_already_released,
                  only: %i[edit edit_submit edit_confirm update]

    def new
      @form = CreateApplicationHoldForm.new(application_form:)
    end

    def new_submit
      @form =
        CreateApplicationHoldForm.new(
          create_form_params.merge!(application_form:, user: current_staff),
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
          create_form_params.merge(application_form:, user: current_staff),
        )

      if @form.save
        session[:"application_hold_#{application_form.reference}"] = nil

        redirect_to confirmation_assessor_interface_application_form_application_hold_path(
                      application_form,
                      application_form.reload.active_application_hold,
                    )
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @form = ReleaseApplicationHoldForm.new(application_hold:)
    end

    def edit_submit
      @form =
        ReleaseApplicationHoldForm.new(
          release_form_params.merge(application_hold:, user: current_staff),
        )

      if @form.valid?
        session[
          :"release_application_hold_#{application_form.reference}"
        ] = @form

        redirect_to [
                      :edit_confirm,
                      :assessor_interface,
                      application_form,
                      application_hold,
                    ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def edit_confirm
      application_hold
      @form = session[:"release_application_hold_#{application_form.reference}"]
    end

    def update
      @form =
        ReleaseApplicationHoldForm.new(
          release_form_params.merge(application_hold:, user: current_staff),
        )

      if @form.save
        session[:"release_application_hold_#{application_form.reference}"] = nil

        redirect_to confirmation_assessor_interface_application_form_application_hold_path(
                      application_form,
                      application_hold,
                    )
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def confirmation
      application_hold
    end

    private

    def application_form
      @application_form ||=
        ApplicationForm.find_by!(reference: params[:application_form_reference])
    end

    def application_hold
      @application_hold ||= application_form.application_holds.find(params[:id])
    end

    def create_form_params
      params.require(:assessor_interface_create_application_hold_form).permit(
        :reason,
        :reason_comment,
      )
    end

    def release_form_params
      params.require(:assessor_interface_release_application_hold_form).permit(
        :release_comment,
      )
    end

    def ensure_application_not_completed
      if application_form.completed_stage?
        flash[:alert] = "Completed applications cannot be put on hold"

        redirect_to assessor_interface_application_form_path(application_form)
      end
    end

    def ensure_application_not_already_on_hold
      if application_form.on_hold?
        flash[:alert] = "Application is already on hold"

        redirect_to assessor_interface_application_form_path(application_form)
      end
    end

    def ensure_application_not_already_released
      if application_hold.released_at.present?
        flash[:alert] = "Application hold has already been released"

        redirect_to assessor_interface_application_form_path(application_form)
      end
    end
  end
end
