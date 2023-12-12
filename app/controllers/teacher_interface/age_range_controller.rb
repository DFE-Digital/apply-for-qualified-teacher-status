# frozen_string_literal: true

module TeacherInterface
  class AgeRangeController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

    def edit
      @form =
        AgeRangeForm.new(
          application_form:,
          minimum: application_form.age_range_min,
          maximum: application_form.age_range_max,
        )
    end

    def update
      @form = AgeRangeForm.new(form_params.merge(application_form:))

      handle_application_form_section(form: @form)
    end

    private

    def form_params
      params.require(:teacher_interface_age_range_form).permit(
        :minimum,
        :maximum,
      )
    end
  end
end
