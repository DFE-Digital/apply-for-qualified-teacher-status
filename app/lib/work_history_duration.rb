# frozen_string_literal: true

class WorkHistoryDuration
  def initialize(application_form:, relation:)
    @application_form = application_form
    @relation =
      relation.where.not(start_date: nil).where.not(hours_per_week: nil)
  end

  def self.for_application_form(application_form)
    WorkHistoryDuration.new(
      application_form:,
      relation: application_form.work_histories,
    )
  end

  def self.for_ids(ids, application_form:)
    WorkHistoryDuration.new(
      application_form:,
      relation: application_form.work_histories.where(id: ids),
    )
  end

  def self.for_record(record)
    for_ids([record.id], application_form: record.application_form)
  end

  def count_months
    work_histories
      .map { |work_history| work_history_full_time_months(work_history) }
      .sum
      .round
  end

  private

  AVERAGE_WEEKS_PER_MONTH = 4.34
  HOURS_PER_FULL_TIME_MONTH = 130.0

  attr_reader :application_form, :relation

  def work_histories
    @work_histories ||=
      relation.order(:start_date).select(
        :start_date,
        :end_date,
        :hours_per_week,
      )
  end

  def work_history_full_time_months(work_history)
    work_history_total_hours(work_history) / HOURS_PER_FULL_TIME_MONTH
  end

  def work_history_total_hours(work_history)
    work_history_hours_per_month(work_history) *
      work_history_number_of_months(work_history)
  end

  def work_history_hours_per_month(work_history)
    [work_history.hours_per_week, 30].min * AVERAGE_WEEKS_PER_MONTH
  end

  def work_history_number_of_months(work_history)
    start = date_first_of_month(work_history.start_date)
    finish = date_first_of_month(work_history.end_date || Time.zone.today)

    date_range(start..finish).every(months: 1).count
  end

  def date_first_of_month(date)
    Date.new(date.year, date.month, 1)
  end

  def date_range(range)
    DateRange.new(range.begin, range.end, range.exclude_end?)
  end

  # https://stackoverflow.com/a/19346914
  class DateRange < Range
    def every(**step)
      current_time = self.begin
      finish_time = self.end
      comparison = exclude_end? ? :< : :<=

      arr = []

      while current_time.send(comparison, finish_time)
        arr << current_time
        current_time = current_time.advance(step)
      end

      arr
    end
  end
end
