# frozen_string_literal: true

module TeacherInterface
  class SubjectsController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

    def edit
      @subjects_form =
        SubjectsForm.new(
          application_form:,
          subject_1: application_form.subjects.first,
          subject_2: application_form.subjects.second,
          subject_3: application_form.subjects.third,
        )
    end

    def update
      @subjects_form =
        SubjectsForm.new(subjects_form_params.merge(application_form:))

      handle_application_form_section(form: @subjects_form)
    end

    private

    def subjects_form_params
      params.require(:teacher_interface_subjects_form).permit(
        :subject_1,
        :subject_2,
        :subject_3,
      )
    end
  end
end
