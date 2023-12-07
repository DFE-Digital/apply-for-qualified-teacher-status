# frozen_string_literal: true

module AssessorInterface
  class ReviewerAssignmentsController < BaseController
    before_action { authorize %i[assessor_interface staff_assignment] }

    def new
      @form =
        ReviewerAssignmentForm.new(
          application_form:,
          reviewer_id: application_form.reviewer_id,
        )
    end

    def create
      @form =
        ReviewerAssignmentForm.new(
          form_params.merge(application_form:, staff: current_staff),
        )

      if @form.save
        redirect_to [:assessor_interface, application_form]
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
      params.require(:assessor_interface_reviewer_assignment_form).permit(
        :reviewer_id,
      )
    end
  end
end
