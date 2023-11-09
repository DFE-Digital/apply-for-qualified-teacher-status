# frozen_string_literal: true

module AssessorInterface
  class ReviewerAssignmentsController < BaseController
    before_action :authorize_assessor

    def new
      @reviewer_assignment_form =
        ReviewerAssignmentForm.new(
          application_form:,
          reviewer_id: application_form.reviewer_id,
        )
    end

    def create
      @reviewer_assignment_form =
        ReviewerAssignmentForm.new(
          application_form:,
          staff: current_staff,
          reviewer_id: reviewer_params[:reviewer_id],
        )

      if @reviewer_assignment_form.save
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

    def reviewer_params
      params.require(:assessor_interface_reviewer_assignment_form).permit(
        :reviewer_id,
      )
    end
  end
end
