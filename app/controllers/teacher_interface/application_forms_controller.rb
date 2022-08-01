class TeacherInterface::ApplicationFormsController < TeacherInterface::BaseController
  before_action :load_application_form, only: %i[show edit update]

  def index
    @application_forms =
      ApplicationForm.where(teacher: current_teacher).order(created_at: :desc)
  end

  def new
    @application_form = ApplicationForm.new
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
  end

  def edit
  end

  def update
    unless @application_form.can_submit?
      redirect_to [:teacher_interface, @application_form]
      return
    end

    @application_form.submitted!
    redirect_to teacher_interface_application_form_path(@application_form)
  end

  private

  def application_form_params
    {
      teacher: current_teacher,
      eligibility_check_id: session[:eligibility_check_id],
      region_id: EligibilityCheck.find(session[:eligibility_check_id]).region_id
    }
  end
end
