# == Schema Information
#
# Table name: countries
#
#  id         :bigint           not null, primary key
#  code       :string           not null
#  legacy     :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_countries_on_code  (code) UNIQUE
#
class Country < ApplicationRecord
  LOCATION_AUTOCOMPLETE_CANONICAL_LIST =
    JSON.parse(File.read("public/location-autocomplete-canonical-list.json"))

  COUNTRY_CODES =
    LOCATION_AUTOCOMPLETE_CANONICAL_LIST.map { |row| row.last.split(":").last }

  validates :code, inclusion: { in: COUNTRY_CODES }
end
