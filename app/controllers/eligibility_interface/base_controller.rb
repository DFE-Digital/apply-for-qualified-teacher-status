module EligibilityInterface
  class BaseController < ApplicationController
    before_action :load_country_name
    after_action :save_eligibility_check_id

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

    def load_country_name
      @country_name =
        CountryName.from_eligibility_check(
          eligibility_check,
          with_definite_article: true
        )
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
