# frozen_string_literal: true

class Filters::SLA::FourtyDay < Filters::Base
  WORKING_DAYS_VISIBLE_FROM = 35

  def apply
    scope
      .includes(:assessment, region: :country)
      .where(stage: %i[pre_assessment not_started assessment])
      .where(
        "working_days_between_submitted_and_today >= ?",
        WORKING_DAYS_VISIBLE_FROM,
      )
  end
end
