# frozen_string_literal: true

class TRS::RecognitionRoute
  class << self
    def for_country_code(country_code, under_old_regulations:)
      if CountryCode.scotland?(country_code)
        "Scotland"
      elsif CountryCode.northern_ireland?(country_code)
        "NorthernIreland"
      elsif under_old_regulations &&
            CountryCode.european_economic_area?(country_code)
        "EuropeanEconomicArea"
      else
        "OverseasTrainedTeachers"
      end
    end
  end
end
