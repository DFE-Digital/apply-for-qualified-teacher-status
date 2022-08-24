class CountryCode
  class << self
    def from_location(location)
      location&.split(":")&.last || ""
    end

    def to_location(code)
      LOCATIONS_BY_COUNTRY_CODE[code]
    end

    LOCATIONS_BY_COUNTRY_CODE =
      Country::LOCATION_AUTOCOMPLETE_CANONICAL_LIST
        .map { |row| [CountryCode.from_location(row.last), row.last] }
        .to_h
  end
end
