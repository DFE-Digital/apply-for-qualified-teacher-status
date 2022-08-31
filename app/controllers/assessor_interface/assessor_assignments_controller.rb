module AssessorInterface
  class AssessorAssignmentsController < BaseController
    def new
      application_form
    end

    def update
      application_form.update!(assessor_id: assessor_params[:assessor_id])
      redirect_to assessor_interface_application_form_path(application_form)
    end

    private

    def application_form
      @application_form ||= ApplicationForm.find(params[:application_form_id])
    end

    def assessor_params
      params.require(:application_form).permit(:assessor_id)
    end
  end
end
