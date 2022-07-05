class CountryName
  class << self
    def from_code(code, with_definite_article: false)
      name = Country::COUNTRIES.fetch(code, "")
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

    def from_eligibility_check(eligibility_check, with_definite_article: false)
      if eligibility_check.region.present?
        from_region(eligibility_check.region, with_definite_article:)
      else
        from_code(eligibility_check.country_code, with_definite_article:)
      end
    end

    COUNTRIES_WITH_DEFINITE_ARTICLE =
      YAML.load(File.read("lib/countries-with-definite-article.yaml"))
  end
end
