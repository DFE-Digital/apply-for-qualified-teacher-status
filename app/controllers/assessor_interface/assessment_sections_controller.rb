# frozen_string_literal: true

module AssessorInterface
  class AssessmentSectionsController < BaseController
    def show
      assessment_section_view_object
    end

    def update
      if UpdateAssessmentSection.call(
           assessment_section:
             assessment_section_view_object.assessment_section,
           user: current_staff,
           params: assessment_section_params
         )
        redirect_to [
                      :assessor_interface,
                      assessment_section_view_object.application_form
                    ]
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def assessment_section_view_object
      @assessment_section_view_object ||=
        AssessmentSectionViewObject.new(params:)
    end

    def assessment_section_params
      params.require(:assessment_section).permit(
        :passed,
        selected_failure_reasons: []
      )
    end
  end
end
