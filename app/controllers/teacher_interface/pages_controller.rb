module TeacherInterface
  class PagesController < BaseController
    before_action :load_eligibility_check

    def eligible
      session[:eligibility_check_complete] = true
    end

    def ineligible
    end

    private

    def load_eligibility_check
      @eligibility_check = eligibility_check
    end
  end
end
