class AssessorInterface::ApplicationFormsController < AssessorInterface::BaseController
  def index
    @application_forms = ApplicationForm.all
  end
end
