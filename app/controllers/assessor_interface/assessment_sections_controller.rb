# frozen_string_literal: true

module AssessorInterface
  class AssessmentSectionsController < BaseController
    before_action :authorize_assessor

    def show
      @form =
        form.new(
          user: current_staff,
          **form_class.initial_attributes(assessment_section),
        )
    end

    def update
      unless view_object.render_form?
        redirect_to [
                      :assessor_interface,
                      application_form,
                      assessment,
                      assessment_section,
                    ]
        return
      end

      @form =
        form.new(form_params.merge(assessment_section:, user: current_staff))

      if @form.save
        redirect_to [:assessor_interface, application_form]
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def view_object
      @view_object ||= AssessmentSectionViewObject.new(params:)
    end

    def form
      form_class.for_assessment_section(assessment_section)
    end

    def form_class
      if assessment_section.age_range_subjects?
        CheckAgeRangeSubjectsForm
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

    def form_params
      form.permit_parameters(
        params.require(:assessor_interface_assessment_section_form),
      )
    end

    delegate :assessment_section,
             :assessment,
             :application_form,
             to: :view_object
  end
end
