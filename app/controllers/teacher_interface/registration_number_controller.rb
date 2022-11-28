# frozen_string_literal: true

module TeacherInterface
  class RegistrationNumberController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form
    before_action :load_teaching_authority_other

    def edit
      @registration_number_form =
        RegistrationNumberForm.new(
          application_form:,
          registration_number: application_form.registration_number,
        )
    end

    def update
      @registration_number_form =
        RegistrationNumberForm.new(
          registration_number_form_params.merge(application_form:),
        )

      handle_application_form_section(
        form: @registration_number_form,
        if_success_then_redirect:,
        if_failure_then_render: :edit,
      )
    end

    private

    def registration_number_form_params
      params.require(:teacher_interface_registration_number_form).permit(
        :registration_number,
      )
    end

    def if_success_then_redirect
      params[:next].presence || %i[teacher_interface application_form]
    end

    def load_teaching_authority_other
      @teaching_authority_other =
        application_form.region.teaching_authority_other
    end
  end
end
