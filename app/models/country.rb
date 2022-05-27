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
  has_many :regions

  LOCATION_AUTOCOMPLETE_CANONICAL_LIST =
    JSON.parse(File.read("public/location-autocomplete-canonical-list.json"))

  COUNTRIES =
    LOCATION_AUTOCOMPLETE_CANONICAL_LIST
      .map { |row| [row.last.split(":").last, row.first] }
      .to_h

  validates :code, inclusion: { in: COUNTRIES.keys }

  def name
    COUNTRIES.fetch(code)
  end
end
