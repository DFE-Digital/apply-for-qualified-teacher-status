module AssessorInterface
  class AssessmentSectionsController < BaseController
    def show
    end

    def update
      if UpdateAssessmentSection.call(
           assessment_section:,
           user: current_staff,
           params: assessment_section_params
         )
        redirect_to [
                      :assessor_interface,
                      assessment_section.assessment.application_form
                    ]
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def assessment_section
      @assessment_section ||=
        AssessmentSection
          .includes(assessment: :application_form)
          .where(
            assessment_id: params[:assessment_id],
            assessment: {
              application_form_id: params[:application_form_id]
            }
          )
          .find_by!(key: params[:key])
    end

    def assessment
      @assessment ||= @assessment_section.assessment
    end

    def application_form
      @application_form ||= assessment.application_form
    end

    def qualifications
      @qualifications ||= application_form.qualifications.ordered
    end

    def work_histories
      @work_histories = application_form.work_histories.ordered
    end

    def assessment_section_params
      params.require(:assessment_section).permit(
        :passed,
        selected_failure_reasons: []
      )
    end
  end
end
