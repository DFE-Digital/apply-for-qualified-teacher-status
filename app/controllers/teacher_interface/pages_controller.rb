module TeacherInterface
  class PagesController < BaseController
    def eligible
      @eligibility_check = EligibilityCheck.find(session[:eligibility_check_id])
      session[:eligibility_check_complete] = true
    end

    def ineligible
      @eligibility_check = EligibilityCheck.find(session[:eligibility_check_id])
    end
  end
end
