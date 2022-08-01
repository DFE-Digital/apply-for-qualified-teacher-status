module TeacherInterface
  class ApplicationFormsController < BaseController
    before_action :load_application_form, only: %i[show edit update]
    before_action :load_eligibility_check, only: %i[new create]

    def index
      @application_forms =
        ApplicationForm.where(teacher: current_teacher).order(created_at: :desc)

      if @application_forms.empty?
        redirect_to %i[new teacher_interface application_form]
      elsif @application_forms.count == 1
        redirect_to [:teacher_interface, @application_forms.first]
      end
    end

    def new
      @application_form = ApplicationForm.new
      @country_region_form = CountryRegionForm.new
    end

    def create
      @application_form = ApplicationForm.new(teacher: current_teacher)

      @country_region_form =
        CountryRegionForm.new(
          country_region_form_params.merge(application_form: @application_form)
        )

      if @country_region_form.needs_region?
        render :new
      elsif @country_region_form.save
        redirect_to teacher_interface_application_form_path(@application_form)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      unless @application_form.can_submit?
        redirect_to [:teacher_interface, @application_form]
        return
      end

      @application_form.submitted!
      redirect_to teacher_interface_application_form_path(@application_form)
    end

    private

    def load_eligibility_check
      @eligibility_check =
        EligibilityCheck.find_by(id: session[:eligibility_check_id])
    end

    def country_region_form_params
      params.require(:teacher_interface_country_region_form).permit(
        :location,
        :region_id
      )
    end
  end
end
