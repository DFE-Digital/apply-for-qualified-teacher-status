module TeacherInterface
  class AgeRangeController < BaseController
    before_action :load_application_form

    def show
      if @application_form.age_range_status == :not_started
        redirect_to [:edit, :teacher_interface, @application_form, :age_range]
      end
    end

    def edit
      @age_range_form =
        AgeRangeForm.new(
          application_form: @application_form,
          age_range_min: @application_form.age_range_min,
          age_range_max: @application_form.age_range_max
        )
    end

    def update
      @age_range_form =
        AgeRangeForm.new(
          age_range_params.merge(application_form: @application_form)
        )
      if @age_range_form.save
        redirect_to [:teacher_interface, @application_form, :age_range]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def age_range_params
      params.require(:teacher_interface_age_range_form).permit(
        :age_range_min,
        :age_range_max
      )
    end
  end
end
