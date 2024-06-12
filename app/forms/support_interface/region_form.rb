# frozen_string_literal: true

class SupportInterface::RegionForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Dirty

  attr_accessor :region
  validates :region, presence: true

  attribute :all_sections_necessary, :boolean
  attribute :other_information, :string
  attribute :requires_preliminary_check, :boolean
  attribute :sanction_check, :string
  attribute :sanction_information, :string
  attribute :status_check, :string
  attribute :status_information, :string
  attribute :teaching_authority_address, :string
  attribute :teaching_authority_certificate, :string
  attribute :teaching_authority_emails_string, :string
  attribute :teaching_authority_name, :string
  attribute :teaching_authority_online_checker_url, :string
  attribute :teaching_authority_provides_written_statement, :boolean
  attribute :teaching_authority_requires_submission_email, :boolean
  attribute :teaching_authority_websites_string, :string
  attribute :teaching_qualification_information, :string
  attribute :work_history_section_to_omit, :string
  attribute :written_statement_optional, :boolean

  validates :all_sections_necessary, inclusion: { in: [true, false] }
  validates :requires_preliminary_check, inclusion: { in: [true, false] }
  validates :sanction_check, inclusion: { in: %w[online written none] }
  validates :status_check, inclusion: { in: %w[online written none] }
  validates :teaching_authority_name,
            format: {
              without: /\Athe.*\z/i,
              message: "Teaching authority name shouldn't start with ‘the’.",
            }
  validates :teaching_authority_online_checker_url, url: { allow_blank: true }
  validates :teaching_authority_provides_written_statement,
            inclusion: {
              in: [true, false],
            }
  validates :work_history_section_to_omit,
            inclusion: {
              in: %w[whole_section contact_details],
            },
            unless: :all_sections_necessary
  validates :written_statement_optional, inclusion: { in: [true, false] }

  def save!
    assign_region_attributes

    ActiveRecord::Base.transaction { region.save! }
  end

  def assign_region_attributes
    region.assign_attributes(
      application_form_skip_work_history:,
      other_information:,
      reduced_evidence_accepted:,
      requires_preliminary_check:,
      sanction_check:,
      sanction_information:,
      status_check:,
      status_information:,
      teaching_authority_address:,
      teaching_authority_certificate:,
      teaching_authority_emails:,
      teaching_authority_name:,
      teaching_authority_online_checker_url:,
      teaching_authority_provides_written_statement:,
      teaching_authority_requires_submission_email:,
      teaching_authority_websites:,
      teaching_qualification_information:,
      written_statement_optional:,
    )
  end

  def teaching_authority_emails
    teaching_authority_emails_string.split("\n").map(&:chomp).compact_blank
  end

  def teaching_authority_websites
    teaching_authority_websites_string.split("\n").map(&:chomp).compact_blank
  end

  def application_form_skip_work_history
    !all_sections_necessary && work_history_section_to_omit == "whole_section"
  end

  def reduced_evidence_accepted
    !all_sections_necessary && work_history_section_to_omit == "contact_details"
  end

  def self.for_existing_region(region)
    all_sections_necessary =
      !region.application_form_skip_work_history &&
        !region.reduced_evidence_accepted

    work_history_section_to_omit =
      if region.application_form_skip_work_history
        "whole_section"
      elsif region.reduced_evidence_accepted
        "contact_details"
      end

    new(
      region:,
      all_sections_necessary:,
      other_information: region.other_information,
      requires_preliminary_check: region.requires_preliminary_check,
      sanction_check: region.sanction_check,
      sanction_information: region.sanction_information,
      status_check: region.status_check,
      status_information: region.status_information,
      teaching_authority_address: region.teaching_authority_address,
      teaching_authority_certificate: region.teaching_authority_certificate,
      teaching_authority_emails_string:
        region.teaching_authority_emails.join("\n"),
      teaching_authority_name: region.teaching_authority_name,
      teaching_authority_online_checker_url:
        region.teaching_authority_online_checker_url,
      teaching_authority_provides_written_statement:
        region.teaching_authority_provides_written_statement,
      teaching_authority_requires_submission_email:
        region.teaching_authority_requires_submission_email,
      teaching_authority_websites_string:
        region.teaching_authority_websites.join("\n"),
      teaching_qualification_information:
        region.teaching_qualification_information,
      work_history_section_to_omit:,
      written_statement_optional: region.written_statement_optional,
    )
  end
end
