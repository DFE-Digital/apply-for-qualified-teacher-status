module TeacherInterface
  class PersonalInformationController < BaseController
    include HandleApplicationFormSection

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

      handle_application_form_section(
        form: @name_and_date_of_birth_form,
        if_success_then_redirect: name_and_date_of_birth_success_path,
        if_failure_then_render: :name_and_date_of_birth,
      )
    end

    def alternative_name
      @alternative_name_form =
        AlternativeNameForm.new(
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

      handle_application_form_section(
        form: @alternative_name_form,
        if_success_then_redirect: -> { alternative_name_success_path },
        if_failure_then_render: :alternative_name,
      )
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

    def name_and_date_of_birth_success_path
      params[:next].presence ||
        %i[
          alternative_name
          teacher_interface
          application_form
          personal_information
        ]
    end

    def alternative_name_success_path
      if @alternative_name_form.has_alternative_name
        teacher_interface_application_form_document_path(
          application_form.name_change_document,
          next: params[:next],
        )
      else
        params[:next].presence ||
          %i[check teacher_interface application_form personal_information]
      end
    end
  end
end
