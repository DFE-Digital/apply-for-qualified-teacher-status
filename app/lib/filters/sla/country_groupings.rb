# frozen_string_literal: true

class Filters::SLA::CountryGroupings < Filters::Base
  def apply
    return scope if country_groupings.nil?

    codes = []

    codes +=
      Country::CODES_IN_UK +
        [Country::GIBRALTAR_CODE] if country_groupings.include?(
      "uk_and_gibraltar",
    )
    codes += Country::CODES_IN_EU if country_groupings.include?("eu")
    codes += Country::CODES_IN_EFTA if country_groupings.include?("efta")
    codes += Country::CODES_IN_REST_OF_WORLD if country_groupings.include?(
      "rest_of_world",
    )

    return scope if codes.empty?

    scope.joins(region: :country).where(regions: { countries: { code: codes } })
  end

  private

  def country_groupings
    params[:country_groupings]
  end
end
