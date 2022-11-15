# frozen_string_literal: true

module AssessorInterface
  class AgeRangeSubjectsController < BaseController
    before_action :set_application_form_and_assessment

    def edit
      @age_range_subjects_form =
        AgeRangeSubjectsForm.new(
          assessment:,
          age_range_min: assessment.age_range_min,
          age_range_max: assessment.age_range_max,
          age_range_note: assessment.age_range_note,
          subject_1: assessment.subjects.first,
          subject_2: assessment.subjects.second,
          subject_3: assessment.subjects.third,
          subjects_note: assessment.subjects_note,
        )
    end

    def update
      @age_range_subjects_form =
        AgeRangeSubjectsForm.new(
          age_range_subjects_form_params.merge(
            assessment:,
            user: current_staff,
          ),
        )

      if @age_range_subjects_form.save
        redirect_to [:edit, :assessor_interface, application_form, assessment]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def assessment
      @assessment ||=
        Assessment
          .includes(:application_form)
          .where(application_form_id: params[:application_form_id])
          .find(params[:assessment_id])
    end

    delegate :application_form, to: :assessment

    def set_application_form_and_assessment
      @application_form = application_form
      @assessment = assessment
    end

    def age_range_subjects_form_params
      params.require(:assessor_interface_age_range_subjects_form).permit(
        :age_range_min,
        :age_range_max,
        :age_range_note,
        :subject_1,
        :subject_2,
        :subject_3,
        :subjects_note,
      )
    end
  end
end
