module TeacherInterface
  class BaseController < ApplicationController
    after_action :save_eligibility_check_id

    def eligibility_check
      @eligibility_check ||=
        if session[:eligibility_check_id]
          EligibilityCheck.find(session[:eligibility_check_id])
        else
          EligibilityCheck.new
        end
    end

    def save_eligibility_check_id
      session[:eligibility_check_id] = eligibility_check.id
    end
  end
end
