module EligibilityInterface
  class BaseController < ApplicationController
    before_action :load_region
    after_action :save_eligibility_check_id

    http_basic_authenticate_with name: ENV.fetch("TEST_USERNAME", "test"),
                                 password: ENV.fetch("TEST_PASSWORD", "test"),
                                 unless: -> {
                                   FeatureFlag.active?(:service_open)
                                 }

    def eligibility_check
      @eligibility_check ||=
        if session[:eligibility_check_id]
          EligibilityCheck.includes(region: :country).find(
            session[:eligibility_check_id]
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

    def current_namespace
      "eligibility"
    end

    MUTUAL_RECOGNITION_URL =
      "https://teacherservices.education.gov.uk/MutualRecognition/".freeze
  end
end
