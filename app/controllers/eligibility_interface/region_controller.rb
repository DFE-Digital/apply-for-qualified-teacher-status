module EligibilityInterface
  class RegionController < BaseController
    include EnforceEligibilityQuestionOrder

    before_action :load_regions

    def new
      @region_form = RegionForm.new(region_id: eligibility_check.region_id)
    end

    def create
      @region_form =
        RegionForm.new(region_form_params.merge(eligibility_check:))
      if @region_form.save
        redirect_to next_url
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def next_url
      {
        eligible: eligibility_interface_qualifications_path,
        legacy: eligibility_interface_eligible_path,
      }.fetch(eligibility_check.region_eligibility_status)
    end

    def region_form_params
      params.require(:eligibility_interface_region_form).permit(:region_id)
    end

    def load_regions
      @regions = eligibility_check.country_regions
    end
  end
end
