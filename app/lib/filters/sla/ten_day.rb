# frozen_string_literal: true

class Filters::SLA::TenDay < Filters::Base
  WORKING_DAYS_NEARING_FROM = 8
  WORKING_DAYS_BREACHED_FROM = 10

  def apply
    scope
      .joins(assessment: :prioritisation_work_history_checks)
      .where(assessment: { started_at: nil }, withdrawn_at: nil)
      .where(
        "working_days_between_submitted_and_today >= ?",
        WORKING_DAYS_NEARING_FROM,
      )
      .distinct
  end
end
