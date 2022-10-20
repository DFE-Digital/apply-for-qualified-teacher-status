# frozen_string_literal: true

class DQT::RecognitionRoute
  class << self
    def for_country_code(country_code)
      if CountryCode.scotland?(country_code)
        "Scotland"
      elsif CountryCode.northern_ireland?(country_code)
        "NorthernIreland"
      elsif CountryCode.european_economic_area?(country_code)
        "EuropeanEconomicArea"
      else
        "OverseasTrainedTeachers"
      end
    end
  end
end
