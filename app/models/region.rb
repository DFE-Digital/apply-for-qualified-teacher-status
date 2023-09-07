# == Schema Information
#
# Table name: regions
#
#  id                                            :bigint           not null, primary key
#  application_form_skip_work_history            :boolean          default(FALSE), not null
#  name                                          :string           default(""), not null
#  other_information                             :text             default(""), not null
#  qualifications_information                    :text             default(""), not null
#  reduced_evidence_accepted                     :boolean          default(FALSE), not null
#  requires_preliminary_check                    :boolean          default(FALSE), not null
#  sanction_check                                :string           default("none"), not null
#  sanction_information                          :string           default(""), not null
#  status_check                                  :string           default("none"), not null
#  status_information                            :string           default(""), not null
#  teaching_authority_address                    :text             default(""), not null
#  teaching_authority_certificate                :text             default(""), not null
#  teaching_authority_emails                     :text             default([]), not null, is an Array
#  teaching_authority_name                       :text             default(""), not null
#  teaching_authority_online_checker_url         :string           default(""), not null
#  teaching_authority_provides_written_statement :boolean          default(FALSE), not null
#  teaching_authority_requires_submission_email  :boolean          default(FALSE), not null
#  teaching_authority_websites                   :text             default([]), not null, is an Array
#  written_statement_optional                    :boolean          default(FALSE), not null
#  created_at                                    :datetime         not null
#  updated_at                                    :datetime         not null
#  country_id                                    :bigint           not null
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

  validates :teaching_authority_online_checker_url, url: { allow_blank: true }

  scope :requires_preliminary_check,
        -> {
          joins(:country).where(requires_preliminary_check: true).or(
            where(country: { requires_preliminary_check: true }),
          )
        }

  def checks_available?
    !sanction_check_none? && !status_check_none?
  end
end
