# frozen_string_literal: true

class ApplicationFormFactory
  include ServicePattern

  def initialize(teacher:, region:)
    @teacher = teacher
    @region = region
  end

  def call
    ApplicationForm.create!(
      teacher:,
      region:,
      needs_work_history:,
      needs_written_statement:,
      teaching_authority_provides_written_statement:,
      needs_registration_number:,
      reduced_evidence_accepted:,
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

  delegate :teaching_authority_provides_written_statement, to: :region

  def needs_registration_number
    region.status_check_online? || region.sanction_check_online?
  end
end
