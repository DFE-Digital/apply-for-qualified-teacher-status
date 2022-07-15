class TeacherInterface::ApplicationFormsController < TeacherInterface::BaseController
  before_action :load_application_form,
                only: %i[show update submit personal_information]

  def index
    @application_forms =
      ApplicationForm.where(teacher: current_teacher).order(created_at: :desc)
  end

  def create
    @application_form = ApplicationForm.new
    if @application_form.update(create_application_form_params)
      redirect_to teacher_interface_application_form_path(@application_form)
    else
      flash[:warning] = "Could not start application."
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def update
    if @application_form.update(update_application_form_params)
      redirect_to [:teacher_interface, @application_form]
    else
      # TODO: this will need to be dynamic
      render :personal_information, status: :unprocessable_entity
    end
  end

  def submit
    @application_form.submitted!
    redirect_to teacher_interface_application_form_path(@application_form)
  end

  def personal_information
  end

  private

  def load_application_form
    @application_form =
      ApplicationForm.where(teacher: current_teacher).find(params[:id])
  end

  def create_application_form_params
    {
      teacher: current_teacher,
      eligibility_check_id: session[:eligibility_check_id]
    }
  end

  def update_application_form_params
    params.require(:application_form).permit(
      :given_names,
      :family_name,
      :date_of_birth
    )
  end
end
