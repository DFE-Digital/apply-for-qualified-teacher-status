module AssessorInterface
  class AssessmentsController < BaseController
    before_action :load_assessment

    def edit
      @application_form = @assessment.application_form
    end

    def update
      if @assessment.update(assessment_params)
        if (new_state = @assessment.application_form_state)
          ChangeApplicationFormState.call(
            application_form: @assessment.application_form,
            user: current_staff,
            new_state:
          )
        end

        redirect_to [:assessor_interface, @assessment.application_form]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def load_assessment
      @assessment =
        Assessment
          .includes(:application_form)
          .where(application_form_id: params[:application_form_id])
          .find(params[:id])
    end

    def assessment_params
      params.require(:assessment).permit(:recommendation)
    end
  end
end
