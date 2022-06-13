# == Schema Information
#
# Table name: countries
#
#  id         :bigint           not null, primary key
#  code       :string           not null
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

  COUNTRIES_WITH_DEFINITE_ARTICLE =
    YAML.load(File.read("lib/countries-with-definite-article.yaml"))

  validates :code, inclusion: { in: COUNTRIES.keys }

  def name
    COUNTRIES.fetch(code)
  end

  def name_with_prefix
    COUNTRIES_WITH_DEFINITE_ARTICLE.include?(code) ? "the #{name}" : name
  end
end
