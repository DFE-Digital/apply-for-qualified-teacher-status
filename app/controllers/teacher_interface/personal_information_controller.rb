module TeacherInterface
  class PersonalInformationController < BaseController
    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

    def show
      if application_form.task_item_completed?(
           :about_you,
           :personal_information,
         )
        redirect_to %i[
                      check
                      teacher_interface
                      application_form
                      personal_information
                    ]
      else
        redirect_to %i[
                      name_and_date_of_birth
                      teacher_interface
                      application_form
                      personal_information
                    ]
      end
    end

    def name_and_date_of_birth
      @name_and_date_of_birth_form =
        NameAndDateOfBirthForm.new(
          application_form:,
          given_names: application_form.given_names,
          family_name: application_form.family_name,
          date_of_birth: application_form.date_of_birth,
        )
    end

    def update_name_and_date_of_birth
      @name_and_date_of_birth_form =
        NameAndDateOfBirthForm.new(
          name_and_date_of_birth_params.merge(application_form:),
        )
      if @name_and_date_of_birth_form.save(validate: true)
        redirect_to_if_save_and_continue %i[
                                           alternative_name
                                           teacher_interface
                                           application_form
                                           personal_information
                                         ]
      else
        render :name_and_date_of_birth, status: :unprocessable_entity
      end
    end

    def alternative_name
      @alternative_name_form =
        AlternativeNameForm.new(
          application_form:,
          has_alternative_name: application_form.has_alternative_name,
          alternative_given_names: application_form.alternative_given_names,
          alternative_family_name: application_form.alternative_family_name,
        )
    end

    def update_alternative_name
      @alternative_name_form =
        AlternativeNameForm.new(
          alternative_name_params.merge(application_form:),
        )
      if @alternative_name_form.save(validate: true)
        redirect_to_if_save_and_continue alternative_name_next_url
      else
        render :alternative_name, status: :unprocessable_entity
      end
    end

    def check
    end

    private

    def name_and_date_of_birth_params
      params.require(:teacher_interface_name_and_date_of_birth_form).permit(
        :given_names,
        :family_name,
        :date_of_birth,
      )
    end

    def alternative_name_params
      params.require(:teacher_interface_alternative_name_form).permit(
        :has_alternative_name,
        :alternative_given_names,
        :alternative_family_name,
      )
    end

    def alternative_name_next_url
      if application_form.has_alternative_name
        [
          :edit,
          :teacher_interface,
          :application_form,
          application_form.name_change_document,
        ]
      else
        %i[check teacher_interface application_form personal_information]
      end
    end
  end
end
