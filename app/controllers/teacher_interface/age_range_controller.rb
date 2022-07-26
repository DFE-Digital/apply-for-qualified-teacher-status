module TeacherInterface
  class AgeRangeController < BaseController
    before_action :load_application_form

    def show
      unless application_form.subsection_started?(
               :your_qualifications,
               :age_range
             )
        redirect_to [:edit, :teacher_interface, application_form, :age_range]
      end
    end

    def edit
      @age_range_form =
        AgeRangeForm.new(
          application_form:,
          age_range_min: application_form.age_range_min,
          age_range_max: application_form.age_range_max
        )
    end

    def update
      @age_range_form =
        AgeRangeForm.new(age_range_params.merge(application_form:))
      if @age_range_form.save
        redirect_to_if_save_and_continue [
                                           :teacher_interface,
                                           application_form,
                                           :age_range
                                         ]
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
