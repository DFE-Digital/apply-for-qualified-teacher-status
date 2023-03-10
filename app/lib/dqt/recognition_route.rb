# frozen_string_literal: true

class DQT::RecognitionRoute
  class << self
    def for_country_code(country_code, under_new_regulations:)
      if CountryCode.scotland?(country_code)
        "Scotland"
      elsif CountryCode.northern_ireland?(country_code)
        "NorthernIreland"
      elsif !under_new_regulations &&
            CountryCode.european_economic_area?(country_code)
        "EuropeanEconomicArea"
      else
        "OverseasTrainedTeachers"
      end
    end
  end
end
