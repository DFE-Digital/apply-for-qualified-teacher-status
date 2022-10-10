module AssessorInterface
  class AssessmentsController < BaseController
    before_action :load_assessment_and_application_form

    def edit
    end

    def update
      if UpdateAssessmentRecommendation.call(
           assessment: @assessment,
           user: current_staff,
           new_recommendation: assessment_params[:recommendation],
         )
        redirect_to post_update_redirect_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def load_assessment_and_application_form
      @assessment =
        Assessment
          .includes(:application_form)
          .where(application_form_id: params[:application_form_id])
          .find(params[:id])

      @application_form = @assessment.application_form
    end

    def assessment_params
      params.require(:assessment).permit(:recommendation)
    end

    def post_update_redirect_path
      if @assessment.request_further_information?
        return [
          :preview,
          :assessor_interface,
          @application_form,
          @assessment,
          :further_information_requests
        ]
      end

      [:assessor_interface, @application_form]
    end
  end
end
