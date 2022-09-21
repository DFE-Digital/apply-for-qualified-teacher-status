module EligibilityInterface
  class BaseController < ApplicationController
    include EligibilityCurrentNamespace

    before_action :load_region
    after_action :save_eligibility_check_id

    def eligibility_check
      @eligibility_check ||=
        if session[:eligibility_check_id]
          EligibilityCheck.includes(region: :country).find(
            session[:eligibility_check_id],
          )
        else
          EligibilityCheck.new
        end
    end

    def load_region
      @region = eligibility_check.region
    end

    def save_eligibility_check_id
      session[:eligibility_check_id] = eligibility_check.id
    end
  end
end
