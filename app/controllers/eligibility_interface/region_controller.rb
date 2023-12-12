# frozen_string_literal: true

module EligibilityInterface
  class RegionController < BaseController
    include EnforceEligibilityQuestionOrder

    before_action :load_regions

    def new
      @form = RegionForm.new(region_id: eligibility_check.region_id)
    end

    def create
      @form = RegionForm.new(form_params.merge(eligibility_check:))
      if @form.save
        redirect_to %i[eligibility_interface qualifications]
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def form_params
      params.require(:eligibility_interface_region_form).permit(:region_id)
    end

    def load_regions
      @regions = eligibility_check.country_regions
    end
  end
end
