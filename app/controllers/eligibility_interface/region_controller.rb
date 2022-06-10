module EligibilityInterface
  class RegionController < BaseController
    before_action :load_regions

    def new
      @region_form = RegionForm.new
    end

    def create
      @region_form =
        RegionForm.new(region_form_params.merge(eligibility_check:))
      if @region_form.save
        redirect_to @region_form.success_url
      else
        render :new
      end
    end

    private

    def region_form_params
      params.require(:region_form).permit(:region_id)
    end

    def load_regions
      @regions = eligibility_check.country_regions
    end
  end
end
