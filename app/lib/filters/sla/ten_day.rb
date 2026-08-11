# frozen_string_literal: true

class Filters::SLA::TenDay < Filters::Base
  WORKING_DAYS_VISIBLE_FROM = 8

  def apply
    scope
      .joins(assessment: :prioritisation_work_history_checks)
      .includes(:assessment, region: :country)
      .where(assessment: { started_at: nil }, withdrawn_at: nil)
      .where(
        "working_days_between_submitted_and_today >= ?",
        WORKING_DAYS_VISIBLE_FROM,
      )
      .distinct
  end
end
