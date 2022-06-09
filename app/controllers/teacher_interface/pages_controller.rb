module TeacherInterface
  class PagesController < BaseController
    before_action :load_eligibility_check
    before_action :complete_eligibility_check, only: %i[eligible ineligible]

    MUTUAL_RECOGNITION_URL =
      "https://teacherservices.education.gov.uk/MutualRecognition/"

    def eligible
      @mutual_recognition_url = MUTUAL_RECOGNITION_URL
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
