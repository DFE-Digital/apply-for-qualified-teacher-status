# frozen_string_literal: true

class Filters::SLA::EightyDay < Filters::Base
  WORKING_DAYS_NEARING_FROM = 65
  WORKING_DAYS_BREACHED_FROM = 80

  def apply
    scope
      .includes(:assessment, region: :country)
      .assessable
      .where(
        "working_days_between_submitted_and_today >= ?",
        WORKING_DAYS_NEARING_FROM,
      )
  end
end
