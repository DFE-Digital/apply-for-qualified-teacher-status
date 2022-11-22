# == Schema Information
#
# Table name: countries
#
#  id                                    :bigint           not null, primary key
#  code                                  :string           not null
#  teaching_authority_address            :text             default(""), not null
#  teaching_authority_certificate        :text             default(""), not null
#  teaching_authority_checks_sanctions   :boolean          default(TRUE), not null
#  teaching_authority_emails             :text             default([]), not null, is an Array
#  teaching_authority_name               :text             default(""), not null
#  teaching_authority_online_checker_url :string           default(""), not null
#  teaching_authority_other              :text             default(""), not null
#  teaching_authority_websites           :text             default([]), not null, is an Array
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#
# Indexes
#
#  index_countries_on_code  (code) UNIQUE
#
class Country < ApplicationRecord
  include TeachingAuthorityContactable

  has_many :regions

  LOCATION_AUTOCOMPLETE_CANONICAL_LIST =
    JSON.parse(File.read("public/location-autocomplete-canonical-list.json"))

  CODES =
    LOCATION_AUTOCOMPLETE_CANONICAL_LIST.map do |row|
      CountryCode.from_location(row.last)
    end

  CODES_IN_EUROPEAN_ECONOMIC_AREA =
    YAML.load(File.read("lib/countries-in-european-economic-area.yaml"))

  validates :code, inclusion: { in: CODES }

  alias_method :country, :itself
end
