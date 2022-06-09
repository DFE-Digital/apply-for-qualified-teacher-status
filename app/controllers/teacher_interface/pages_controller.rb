module TeacherInterface
  class PagesController < BaseController
    before_action :load_eligibility_check, except: %i[root]
    before_action :complete_eligibility_check, only: %i[eligible ineligible]

    MUTUAL_RECOGNITION_URL =
      "https://teacherservices.education.gov.uk/MutualRecognition/"

    def root
      redirect_to teacher_interface_start_url
    end

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
