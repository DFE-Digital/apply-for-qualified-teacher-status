module TeacherInterface
  class RegistrationNumberController < BaseController
    before_action :load_application_form

    def show
      unless application_form.task_item_started?(
               :proof_of_recognition,
               :registration_number
             )
        redirect_to [
                      :edit,
                      :teacher_interface,
                      application_form,
                      :registration_number
                    ]
      end
    end

    def edit
      @registration_number_form =
        RegistrationNumberForm.new(
          application_form:,
          registration_number: application_form.registration_number
        )
    end

    def update
      @registration_number_form =
        RegistrationNumberForm.new(
          registration_number_params.merge(application_form:)
        )
      if @registration_number_form.save
        redirect_to_if_save_and_continue [
                                           :teacher_interface,
                                           application_form,
                                           :registration_number
                                         ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def registration_number_params
      params.require(:teacher_interface_registration_number_form).permit(
        :registration_number
      )
    end
  end
end
