class TeacherInterface::PersonalInformationController < TeacherInterface::BaseController
  before_action :load_application_form

  def show
    unless @application_form.personal_information_status == :completed
      redirect_to [
                    :edit,
                    :teacher_interface,
                    @application_form,
                    :personal_information
                  ]
    end
  end

  def edit
  end

  def update
    if @application_form.update(personal_information_params)
      redirect_to [:teacher_interface, @application_form, :personal_information]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def personal_information_params
    params.require(:application_form).permit(
      :given_names,
      :family_name,
      :date_of_birth
    )
  end
end
