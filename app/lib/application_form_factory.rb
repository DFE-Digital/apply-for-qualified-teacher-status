# frozen_string_literal: true

class ApplicationFormFactory
  include ServicePattern

  def initialize(teacher:, region:)
    @teacher = teacher
    @region = region
  end

  def call
    ActiveRecord::Base.transaction do
      ApplicationForm.create!(
        needs_registration_number:,
        needs_work_history:,
        needs_written_statement:,
        reduced_evidence_accepted:,
        reference:,
        region:,
        requires_preliminary_check:,
        teacher:,
        teaching_authority_provides_written_statement:,
        written_statement_optional:,
      )
    end
  end

  private

  attr_reader :teacher, :region

  delegate :reduced_evidence_accepted,
           :teaching_authority_provides_written_statement,
           :written_statement_optional,
           to: :region

  def reference
    ActiveRecord::Base.connection.execute(
      "LOCK TABLE application_forms IN EXCLUSIVE MODE",
    )

    max_reference = ApplicationForm.maximum(:reference)&.to_i
    max_reference = 2_000_000 if max_reference.nil? || max_reference.zero?

    (max_reference + 1).to_s.rjust(7, "0")
  end

  def needs_work_history
    !region.application_form_skip_work_history
  end

  def needs_written_statement
    region.status_check_written? || region.sanction_check_written?
  end

  def needs_registration_number
    region.status_check_online? || region.sanction_check_online?
  end

  def requires_preliminary_check
    region.requires_preliminary_check
  end
end
