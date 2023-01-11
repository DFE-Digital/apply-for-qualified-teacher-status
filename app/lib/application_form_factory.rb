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
      needs_registration_number:,
    )
  end

  private

  attr_reader :teacher, :region

  def needs_work_history
    if FeatureFlags::FeatureFlag.active?(:application_work_history)
      !region.application_form_skip_work_history
    else
      region.status_check_none? || region.sanction_check_none?
    end
  end

  def needs_written_statement
    region.status_check_written? || region.sanction_check_written?
  end

  def needs_registration_number
    region.status_check_online? || region.sanction_check_online?
  end
end
