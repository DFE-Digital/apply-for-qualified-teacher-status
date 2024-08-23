# frozen_string_literal: true

module TeacherInterface
  class RegistrationNumberController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

    def edit
      @form =
        RegistrationNumberForm.new(
          application_form:,
          registration_number: application_form.registration_number,
        )
    end

    def update
      @form = RegistrationNumberForm.new(form_params.merge(application_form:))

      handle_application_form_section(form: @form)
    end

    private

    def form_params
      params.require(:teacher_interface_registration_number_form).permit(
        :registration_number,
        license_number_parts: [],
      )
    end
  end
end
