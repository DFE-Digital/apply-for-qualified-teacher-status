class TeacherInterface::ApplicationFormsController < TeacherInterface::BaseController
  def index
    @application_forms =
      ApplicationForms.where(teacher: current_teacher).order(created_at: :desc)
  end

  def create
    @application_form = ApplicationForm.new
    if @application_form.update(application_form_params)
      redirect_to teacher_interface_application_form_path(@application_form)
    else
      flash[:warning] = "Could not start application."
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @application_form =
      ApplicationForm.where(teacher: current_teacher).find(params[:id])
  end

  private

  def application_form_params
    {
      teacher: current_teacher,
      eligibility_check_id: session[:eligibility_check_id]
    }
  end
end
