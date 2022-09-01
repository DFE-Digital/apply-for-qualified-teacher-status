module AssessorInterface
  class CompleteAssessmentsController < BaseController
    def new
      @complete_assessment_form =
        CompleteAssessmentForm.new(application_form:, staff: current_staff)
    end

    def create
      @complete_assessment_form =
        CompleteAssessmentForm.new(
          application_form:,
          staff: current_staff,
          new_state: complete_assessments_form_params[:new_state]
        )

      if @complete_assessment_form.save!
        redirect_to [:assessor_interface, application_form]
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def application_form
      @application_form ||= ApplicationForm.find(params[:application_form_id])
    end

    def complete_assessments_form_params
      params.require(:assessor_interface_complete_assessment_form).permit(
        :new_state
      )
    end
  end
end
