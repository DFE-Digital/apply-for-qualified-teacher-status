module EligibilityInterface
  class CountriesController < BaseController
    include EnforceEligibilityQuestionOrder

    def new
      @country_form = CountryForm.new(location: eligibility_check.location)
    end

    def create
      @country_form =
        CountryForm.new(location_form_params.merge(eligibility_check:))
      if @country_form.save
        redirect_to next_url
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def next_url
      {
        eligible: eligibility_interface_qualifications_path,
        ineligible: eligibility_interface_result_path,
        region: eligibility_interface_region_path,
      }.fetch(eligibility_check.country_eligibility_status)
    end

    def location_form_params
      params.require(:eligibility_interface_country_form).permit(:location)
    end
  end
end
