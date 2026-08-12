# frozen_string_literal: true

class Filters::SLA::FourtyDay < Filters::Base
  WORKING_DAYS_NEARING_FROM = 35
  WORKING_DAYS_BREACHED_FROM = 40

  def apply
    scope.where(stage: %i[pre_assessment not_started assessment]).where(
      "working_days_between_submitted_and_today >= ?",
      WORKING_DAYS_NEARING_FROM,
    )
  end
end
