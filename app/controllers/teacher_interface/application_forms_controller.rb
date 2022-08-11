module TeacherInterface
  class ApplicationFormsController < BaseController
    before_action :load_application_form, except: %i[new create]

    def new
      @application_form = ApplicationForm.new
      @country_region_form = CountryRegionForm.new
    end

    def create
      @application_form = ApplicationForm.new(teacher: current_teacher)

      @country_region_form =
        CountryRegionForm.new(
          country_region_form_params.merge(application_form:)
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
      @application_form.submit! if @application_form.can_submit?
      redirect_to %i[teacher_interface application_form]
    end

    private

    def country_region_form_params
      params.require(:teacher_interface_country_region_form).permit(
        :location,
        :region_id
      )
    end
  end
end
