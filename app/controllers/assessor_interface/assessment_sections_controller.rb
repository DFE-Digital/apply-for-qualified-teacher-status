module AssessorInterface
  class AssessmentSectionsController < BaseController
    before_action :load_assessment_section_and_assessment

    def show
    end

    def update
      if @assessment_section.update(assessment_section_params)
        redirect_to [
                      :assessor_interface,
                      @assessment_section.assessment.application_form
                    ]
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def load_assessment_section_and_assessment
      @assessment_section =
        AssessmentSection
          .includes(assessment: :application_form)
          .where(
            assessment_id: params[:assessment_id],
            assessment: {
              application_form_id: params[:application_form_id]
            }
          )
          .find_by!(key: params[:key])

      @assessment = @assessment_section.assessment
      @application_form = @assessment.application_form
      @qualifications = @application_form.qualifications.ordered
      @work_histories = @application_form.work_histories.ordered
    end

    def assessment_section_params
      params.require(:assessment_section).permit(
        :passed,
        selected_failure_reasons: []
      )
    end
  end
end
