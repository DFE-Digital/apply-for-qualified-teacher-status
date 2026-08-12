# frozen_string_literal: true

class Filters::SLA::CountryGroupings < Filters::Base
  def apply
    scope
  end

  private

  def country_groupings
    params[:country_groupings]
  end
end
