module TeacherInterface
  class ApplicationFormsController < BaseController
    before_action :load_application_form, except: %i[new create]

    def new
      @country_region_form = CountryRegionForm.new
    end

    def create
      @country_region_form =
        CountryRegionForm.new(
          country_region_form_params.merge(teacher: current_teacher),
        )

      if @country_region_form.needs_region?
        render :new
      elsif @country_region_form.save
        redirect_to teacher_interface_application_form_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      unless @application_form
        redirect_to %i[new teacher_interface application_form]
      end
    end

    def edit
    end

    def update
      if application_form.can_submit?
        SubmitApplicationForm.call(application_form:, user: current_teacher)
      end

      redirect_to %i[teacher_interface application_form]
    end

    private

    def country_region_form_params
      params.require(:teacher_interface_country_region_form).permit(
        :location,
        :region_id,
      )
    end
  end
end
