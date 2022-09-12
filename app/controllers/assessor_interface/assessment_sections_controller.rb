module AssessorInterface
  class AssessmentSectionsController < BaseController
    def show
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

      @application_form = @assessment_section.assessment.application_form
      @qualifications = @application_form.qualifications.ordered
      @work_histories = @application_form.work_histories.ordered
    end
  end
end
