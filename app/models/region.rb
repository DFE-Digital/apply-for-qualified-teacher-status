# == Schema Information
#
# Table name: regions
#
#  id                          :bigint           not null, primary key
#  application_form_enabled    :boolean          default(FALSE)
#  legacy                      :boolean          default(TRUE), not null
#  name                        :string           default(""), not null
#  sanction_check              :string           default("none"), not null
#  status_check                :string           default("none"), not null
#  teaching_authority_address  :text             default(""), not null
#  teaching_authority_emails   :text             default([]), not null, is an Array
#  teaching_authority_name     :text             default(""), not null
#  teaching_authority_other    :text             default(""), not null
#  teaching_authority_websites :text             default([]), not null, is an Array
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  country_id                  :bigint           not null
#
# Indexes
#
#  index_regions_on_country_id           (country_id)
#  index_regions_on_country_id_and_name  (country_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
class Region < ApplicationRecord
  include TeachingAuthorityContactable

  belongs_to :country
  has_many :eligibility_checks

  enum :sanction_check,
       { none: "none", online: "online", written: "written" },
       default: :none,
       prefix: true
  enum :status_check,
       { none: "none", online: "online", written: "written" },
       default: :none,
       prefix: true

  validates :name, uniqueness: { scope: :country_id }
  validates :sanction_check, inclusion: { in: sanction_checks.values }
  validates :status_check, inclusion: { in: status_checks.values }
end
