module TeacherInterface
  class PersonalInformationController < BaseController
    before_action :load_application_form

    def show
      unless application_form.subsection_started?(
               :about_you,
               :personal_information
             )
        redirect_to [
                      :edit,
                      :teacher_interface,
                      application_form,
                      :personal_information
                    ]
      end
    end

    def edit
      @name_and_date_of_birth_form =
        NameAndDateOfBirthForm.new(
          application_form:,
          given_names: application_form.given_names,
          family_name: application_form.family_name,
          date_of_birth: application_form.date_of_birth
        )
    end

    def update
      @name_and_date_of_birth_form =
        NameAndDateOfBirthForm.new(
          name_and_date_of_birth_params.merge(application_form:)
        )
      if @name_and_date_of_birth_form.save
        redirect_to_if_save_and_continue [
                                           :teacher_interface,
                                           application_form,
                                           :personal_information
                                         ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def name_and_date_of_birth_params
      params.require(:teacher_interface_name_and_date_of_birth_form).permit(
        :given_names,
        :family_name,
        :date_of_birth
      )
    end
  end
end
