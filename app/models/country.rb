# frozen_string_literal: true

# == Schema Information
#
# Table name: countries
#
#  id                                 :bigint           not null, primary key
#  code                               :string           not null
#  eligibility_enabled                :boolean          default(TRUE), not null
#  eligibility_skip_questions         :boolean          default(FALSE), not null
#  other_information                  :text             default(""), not null
#  sanction_information               :string           default(""), not null
#  status_information                 :string           default(""), not null
#  subject_limited                    :boolean          default(FALSE), not null
#  teaching_qualification_information :text             default(""), not null
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#
# Indexes
#
#  index_countries_on_code  (code) UNIQUE
#
class Country < ApplicationRecord
  has_many :regions

  LOCATION_AUTOCOMPLETE_CANONICAL_LIST =
    JSON.parse(File.read("public/location-autocomplete-canonical-list.json"))

  CODES =
    LOCATION_AUTOCOMPLETE_CANONICAL_LIST.map do |row|
      CountryCode.from_location(row.last)
    end

  CODES_IN_EUROPEAN_ECONOMIC_AREA =
    YAML.load(File.read("lib/countries-in-european-economic-area.yaml"))

  CODES_IN_EU = YAML.load(File.read("lib/countries-in-eu.yaml"))

  CODES_IN_EFTA = %w[CH IS LI NO].freeze

  CODES_IN_UK = %w[GB-ENG GB-NIR GB-WLS GB-SCT].freeze

  GIBRALTAR_CODE = "GI"

  CODES_IN_REST_OF_WORLD =
    CODES - CODES_IN_EU - CODES_IN_EFTA - CODES_IN_UK - [GIBRALTAR_CODE]

  validates :code, inclusion: { in: CODES }
end
