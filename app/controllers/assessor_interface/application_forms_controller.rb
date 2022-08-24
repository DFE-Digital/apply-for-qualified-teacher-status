class AssessorInterface::ApplicationFormsController < AssessorInterface::BaseController
  def index
    @application_forms = ApplicationForm.all
  end

  def show
    @application_form = ApplicationForm.find(params[:id])
  end
end
