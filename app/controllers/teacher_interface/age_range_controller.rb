module TeacherInterface
  class AgeRangeController < BaseController
    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form

    def edit
      @age_range_form =
        AgeRangeForm.new(
          application_form:,
          minimum: application_form.age_range_min,
          maximum: application_form.age_range_max,
        )
    end

    def update
      @age_range_form =
        AgeRangeForm.new(age_range_form_params.merge(application_form:))
      if @age_range_form.save
        redirect_to %i[teacher_interface application_form]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def age_range_form_params
      params.require(:teacher_interface_age_range_form).permit(
        :minimum,
        :maximum,
      )
    end
  end
end
