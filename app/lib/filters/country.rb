# frozen_string_literal: true

class Filters::Country < Filters::Base
  def apply
    return scope if location.blank?

    code = CountryCode.from_location(location)

    scope.joins(region: :country).where(regions: { countries: { code: } })
  end

  private

  def location
    params[:location]
  end
end
