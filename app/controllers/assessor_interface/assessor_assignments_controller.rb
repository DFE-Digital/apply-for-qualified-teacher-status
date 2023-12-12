# frozen_string_literal: true

module AssessorInterface
  class AssessorAssignmentsController < BaseController
    before_action :authorize_assessor

    def new
      @form =
        AssessorAssignmentForm.new(
          application_form:,
          assessor_id: application_form.assessor_id,
        )
    end

    def create
      @form =
        AssessorAssignmentForm.new(
          form_params.merge(application_form:, staff: current_staff),
        )

      if @form.save
        redirect_to [:assessor_interface, @application_form]
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def application_form
      @application_form ||=
        ApplicationForm.find_by!(reference: params[:application_form_reference])
    end

    def form_params
      params.require(:assessor_interface_assessor_assignment_form).permit(
        :assessor_id,
      )
    end
  end
end
