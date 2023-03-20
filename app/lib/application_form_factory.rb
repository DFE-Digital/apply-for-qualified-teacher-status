# frozen_string_literal: true

class ApplicationFormFactory
  include ServicePattern

  def initialize(teacher:, region:)
    @teacher = teacher
    @region = region
  end

  def call
    ApplicationForm.create!(
      needs_registration_number:,
      needs_work_history:,
      needs_written_statement:,
      reduced_evidence_accepted:,
      region:,
      teacher:,
      teaching_authority_provides_written_statement:,
      written_statement_optional:,
      requires_preliminary_check:,
    )
  end

  private

  attr_reader :teacher, :region

  delegate :reduced_evidence_accepted, to: :region

  def needs_work_history
    !region.application_form_skip_work_history
  end

  def needs_written_statement
    region.status_check_written? || region.sanction_check_written?
  end

  delegate :teaching_authority_provides_written_statement,
           :written_statement_optional,
           to: :region

  def needs_registration_number
    region.status_check_online? || region.sanction_check_online?
  end

  def requires_preliminary_check
    region.requires_preliminary_check ||
      region.country.requires_preliminary_check
  end
end
