# frozen_string_literal: true

module TeacherInterface
  class RegistrationNumberController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

    def edit
      @form = form_class.new(
          application_form:,
          registration_number: application_form.registration_number,
        )

      render view_name
    end

    def update
      @form = form_class.new(form_params.merge(application_form:))

      handle_application_form_section(
        form: @form,
        if_failure_then_render: view_name,
      )
    end

    private

    def ghana?
      CountryCode.ghana?(application_form.country.code)
    end

    def form_params
      if ghana?
        params.require(:teacher_interface_ghana_registration_number_form).permit(
          :license_number_part_one,
          :license_number_part_two,
          :license_number_part_three,
        )
      else
        params.require(:teacher_interface_registration_number_form).permit(
          :registration_number,
        )
      end
    end

    def view_name
      ghana? ? :edit_ghana : :edit
    end

    def form_class
      ghana? ? GhanaRegistrationNumberForm : RegistrationNumberForm
    end
  end
end
