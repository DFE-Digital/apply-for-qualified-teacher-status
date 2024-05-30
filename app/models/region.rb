# == Schema Information
#
# Table name: regions
#
#  id                                            :bigint           not null, primary key
#  application_form_skip_work_history            :boolean          default(FALSE), not null
#  name                                          :string           default(""), not null
#  other_information                             :text             default(""), not null
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
#  teaching_qualification_information            :text             default(""), not null
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

  validates :teaching_authority_name,
            format: {
              without: /\Athe.*\z/i,
              message: "Teaching authority name shouldn't start with ‘the’.",
            }
  validates :teaching_authority_online_checker_url, url: { allow_blank: true }

  def checks_available?
    !sanction_check_none? && !status_check_none?
  end

  def teaching_authority_emails_string
    teaching_authority_emails.join("\n")
  end

  def teaching_authority_emails_string=(string)
    self.teaching_authority_emails =
      string.split("\n").map(&:chomp).compact_blank
  end

  def teaching_authority_websites_string
    teaching_authority_websites.join("\n")
  end

  def teaching_authority_websites_string=(string)
    self.teaching_authority_websites =
      string.split("\n").map(&:chomp).compact_blank
  end

  def teaching_authority_present?
    teaching_authority_name.present? || teaching_authority_address.present? ||
      teaching_authority_emails.present? || teaching_authority_websites.present?
  end

  def all_sections_necessary
    !application_form_skip_work_history && !reduced_evidence_accepted
  end

  def all_sections_necessary=(value)
    application_form_skip_work_history_will_change!
    reduced_evidence_accepted_will_change!

    if value
      self.application_form_skip_work_history = false
      self.reduced_evidence_accepted = false
    end
  end

  def work_history_section_to_omit
    if application_form_skip_work_history
      "whole_section"
    elsif reduced_evidence_accepted
      "contact_details"
    end
  end

  def work_history_section_to_omit=(value)
    return if all_sections_necessary
    application_form_skip_work_history_will_change!
    reduced_evidence_accepted_will_change!

    case value
    when "whole_section"
      self.application_form_skip_work_history = true
      self.reduced_evidence_accepted = false
    when "contact_details"
      self.application_form_skip_work_history = false
      self.reduced_evidence_accepted = true
    end
  end
end
