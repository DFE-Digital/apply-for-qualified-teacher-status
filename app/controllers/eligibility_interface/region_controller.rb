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
        redirect_to eligibility_interface_qualifications_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def region_form_params
      params.require(:eligibility_interface_region_form).permit(:region_id)
    end

    def load_regions
      @regions = eligibility_check.country_regions
    end
  end
end
