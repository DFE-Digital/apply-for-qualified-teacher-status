# frozen_string_literal: true

class CountryName
  class << self
    def from_code(code, with_definite_article: false)
      name = NAMES_BY_COUNTRY_CODE.fetch(code, "")
      return name unless with_definite_article
      COUNTRIES_WITH_DEFINITE_ARTICLE.include?(code) ? "the #{name}" : name
    end

    def from_country(country, with_definite_article: false)
      from_code(country.code, with_definite_article:)
    end

    def from_region(region, with_definite_article: false)
      region.name.presence ||
        from_country(region.country, with_definite_article:)
    end

    def from_region_with_country(region, with_definite_article: false)
      if region.name.presence
        "#{region.name.presence}, #{from_code(region.country.code, with_definite_article:)}"
      else
        from_region(region, with_definite_article:)
      end
    end

    def from_eligibility_check(eligibility_check, with_definite_article: false)
      if eligibility_check.region.present?
        from_country(eligibility_check.region.country, with_definite_article:)
      else
        from_code(eligibility_check.country_code, with_definite_article:)
      end
    end

    NAMES_BY_COUNTRY_CODE =
      Country::LOCATION_AUTOCOMPLETE_CANONICAL_LIST
        .map { |row| [CountryCode.from_location(row.last), row.first] }
        .to_h

    COUNTRIES_WITH_DEFINITE_ARTICLE =
      YAML.load(File.read("lib/countries-with-definite-article.yaml"))
  end
end
