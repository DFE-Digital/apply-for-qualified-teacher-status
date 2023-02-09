# frozen_string_literal: true

module AssessorInterface
  class AssessmentSectionsController < BaseController
    before_action :authorize_assessor

    def show
      @assessment_section_form =
        assessment_section_form.new(
          user: current_staff,
          **assessment_section_form_class.initial_attributes(
            assessment_section,
          ),
        )
    end

    def update
      unless assessment_section_view_object.render_form?
        redirect_to assessor_interface_application_form_assessment_assessment_section_path(
                      assessment_section_view_object.application_form,
                      assessment_section_view_object.assessment,
                      assessment_section_view_object.assessment_section.key,
                    )
        return
      end

      @assessment_section_form =
        assessment_section_form.new(
          assessment_section_form_params.merge(
            assessment_section:,
            user: current_staff,
          ),
        )

      if @assessment_section_form.save
        redirect_to [
                      :assessor_interface,
                      assessment_section_view_object.application_form,
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

    def assessment_section_form
      assessment_section_form_class.for_assessment_section(assessment_section)
    end

    def assessment_section_form_class
      if assessment_section.age_range_subjects?
        AgeRangeSubjectsForm
      elsif assessment_section.professional_standing? &&
            application_form.created_under_new_regulations? &&
            !application_form.needs_work_history
        InductionRequiredForm
      elsif application_form.english_language_exempt? &&
            assessment_section.personal_information?
        PersonalInformationForm
      elsif application_form.english_language_exempt? &&
            assessment_section.qualifications?
        QualificationsForm
      else
        AssessmentSectionForm
      end
    end

    def assessment_section_form_params
      assessment_section_form.permit_parameters(
        params.require(:assessor_interface_assessment_section_form),
      )
    end

    delegate :assessment_section,
             :application_form,
             to: :assessment_section_view_object
  end
end
