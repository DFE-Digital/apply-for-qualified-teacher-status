# frozen_string_literal: true

class WorkingDays::BaseJob < ApplicationJob
  private

  def calendar
    @calendar ||=
      Business::Calendar.new(
        holidays:
          DfE::ReferenceData::BankHolidays::BANK_HOLIDAYS.all.map(&:date),
      )
  end

  def today
    @today ||= Time.zone.now
  end
end
