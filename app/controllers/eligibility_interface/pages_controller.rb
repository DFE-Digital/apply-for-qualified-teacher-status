module EligibilityInterface
  class PagesController < BaseController
    before_action :load_eligibility_check, except: %i[root]
    before_action :complete_eligibility_check, only: %i[eligible ineligible]

    MUTUAL_RECOGNITION_URL =
      "https://teacherservices.education.gov.uk/MutualRecognition/".freeze

    def root
      if FeatureFlag.active?(:service_start)
        redirect_to eligibility_interface_start_url
      else
        redirect_to MUTUAL_RECOGNITION_URL, allow_other_host: true
      end
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
