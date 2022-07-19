# == Schema Information
#
# Table name: countries
#
#  id                             :bigint           not null, primary key
#  code                           :string           not null
#  teaching_authority_address     :text             default(""), not null
#  teaching_authority_certificate :text             default(""), not null
#  teaching_authority_emails      :text             default([]), not null, is an Array
#  teaching_authority_name        :text             default(""), not null
#  teaching_authority_other       :text             default(""), not null
#  teaching_authority_websites    :text             default([]), not null, is an Array
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
# Indexes
#
#  index_countries_on_code  (code) UNIQUE
#
class Country < ApplicationRecord
  include DfE::Analytics::Entities
  include TeachingAuthorityContactable

  has_many :regions

  LOCATION_AUTOCOMPLETE_CANONICAL_LIST =
    JSON.parse(File.read("public/location-autocomplete-canonical-list.json"))

  COUNTRIES =
    LOCATION_AUTOCOMPLETE_CANONICAL_LIST
      .map { |row| [row.last.split(":").last, row.first] }
      .to_h

  validates :code, inclusion: { in: COUNTRIES.keys }

  alias_method :country, :itself
end
