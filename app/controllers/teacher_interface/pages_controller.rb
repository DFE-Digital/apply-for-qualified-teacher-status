module TeacherInterface
  class PagesController < BaseController
    before_action :load_eligibility_check
    before_action :complete_eligibility_check, only: %i[eligible ineligible]

    def eligible
      session[:eligibility_check_complete] = true
    end

    def ineligible
    end

    private

    def complete_eligibility_check
      @eligibility_check.complete!
    end

    def load_eligibility_check
      @eligibility_check = eligibility_check
    end
  end
end
