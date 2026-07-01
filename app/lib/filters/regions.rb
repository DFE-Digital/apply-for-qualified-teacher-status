# frozen_string_literal: true

class Filters::Regions < Filters::Base
  def apply
    return scope if country.blank? || regions.empty?

    scope.where(region: regions)
  end

  private

  def country
    @country ||= Country.find_by(code: country_code)
  end

  def country_code
    @country_code ||= CountryCode.from_location(params[:location])
  end

  def region_ids
    params[:region_ids]
  end

  def regions
    Region.where(id: region_ids, country:)
  end
end
