class CountryCode
  class << self
    def from_location(location)
      location&.split(":")&.last || ""
    end

    def to_location(code)
      LOCATIONS_BY_COUNTRY_CODE[code]
    end

    def england?(code)
      code == "GB-ENG"
    end

    def wales?(code)
      code == "GB-WLS"
    end

    def scotland?(code)
      code == "GB-SCT"
    end

    def northern_ireland?(code)
      code == "GB-NIR"
    end

    def european_economic_area?(code)
      Country::CODES_IN_EUROPEAN_ECONOMIC_AREA.include?(code)
    end

    def secondary_education_teaching_qualification_required?(code)
      Country::CODES_REQUIRING_SECONDARY_EDUCATION_TEACHING_QUALIFICATION.include?(
        code,
      )
    end

    LOCATIONS_BY_COUNTRY_CODE =
      Country::LOCATION_AUTOCOMPLETE_CANONICAL_LIST
        .map { |row| [CountryCode.from_location(row.last), row.last] }
        .to_h
  end
end
