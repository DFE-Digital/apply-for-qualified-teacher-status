module TeacherInterface
  class RegistrationNumberController < BaseController
    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

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
      if @registration_number_form.save
        redirect_to %i[teacher_interface application_form]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def registration_number_form_params
      params.require(:teacher_interface_registration_number_form).permit(
        :registration_number,
      )
    end
  end
end
