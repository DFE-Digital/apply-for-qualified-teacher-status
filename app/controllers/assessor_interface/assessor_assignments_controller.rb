# frozen_string_literal: true

module AssessorInterface
  class AssessorAssignmentsController < BaseController
    before_action :authorize_assessor

    def new
      @assessor_assignment_form =
        AssessorAssignmentForm.new(
          application_form:,
          assessor_id: application_form.assessor_id,
        )
    end

    def create
      @assessor_assignment_form =
        AssessorAssignmentForm.new(
          application_form:,
          staff: current_staff,
          assessor_id: assessor_params[:assessor_id],
        )

      if @assessor_assignment_form.save
        redirect_to assessor_interface_application_form_path(application_form)
      else
        render :new
      end
    end

    private

    def application_form
      @application_form ||=
        ApplicationForm.find_by!(reference: params[:application_form_reference])
    end

    def assessor_params
      params.require(:assessor_interface_assessor_assignment_form).permit(
        :assessor_id,
      )
    end
  end
end
