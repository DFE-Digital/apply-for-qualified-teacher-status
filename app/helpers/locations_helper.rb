# frozen_string_literal: true

module LocationsHelper
  def locations
    Country::LOCATION_AUTOCOMPLETE_CANONICAL_LIST
  end
end
