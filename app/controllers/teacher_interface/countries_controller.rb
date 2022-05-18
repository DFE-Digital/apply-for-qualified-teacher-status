module TeacherInterface
  class CountriesController < BaseController
    def new
      @country_form = CountryForm.new
    end

    def create
      eligibility_check = EligibilityCheck.new
      @country_form =
        CountryForm.new(country_form_params.merge(eligibility_check:))
      if @country_form.save
        session[:eligibility_check_id] = eligibility_check.id
        redirect_to(
          if @country_form.recognised
            teacher_interface_misconduct_url
          else
            teacher_interface_ineligible_url
          end
        )
      else
        render :new
      end
    end

    private

    def country_form_params
      params.require(:country_form).permit(:recognised)
    end
  end
end
