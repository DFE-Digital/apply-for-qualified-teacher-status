module AssessorInterface
  class AssessorAssignmentsController < BaseController
    def new
      @assessor_assignment_form =
        AssessorAssignmentForm.new(
          assessor_id: application_form.assessor_id,
          application_form:
        )
    end

    def create
      @assessor_assignment_form =
        AssessorAssignmentForm.new(
          assessor_id: assessor_params[:assessor_id],
          application_form:,
          assigning_user_id: current_staff.id
        )

      if @assessor_assignment_form.save!
        redirect_to assessor_interface_application_form_path(application_form)
      else
        render :new
      end
    end

    private

    def application_form
      @application_form ||= ApplicationForm.find(params[:application_form_id])
    end

    def assessor_params
      params.require(:assessor_interface_assessor_assignment_form).permit(
        :assessor_id
      )
    end
  end
end
