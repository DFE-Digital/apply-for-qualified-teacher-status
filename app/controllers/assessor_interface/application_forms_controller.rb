class AssessorInterface::ApplicationFormsController < AssessorInterface::BaseController
  def index
    @application_forms =
      ::Filters::ALL.reduce(ApplicationForm.active) do |scope, filter|
        filter.apply(scope:, params:)
      end
  end

  def show
    @application_form = ApplicationForm.find(params[:id])
  end
end
