# frozen_string_literal: true

class WorkHistoryDuration
  def initialize(application_form: nil, work_history_relation: nil)
    if !application_form.nil? && work_history_relation.nil?
      @work_history_relation =
        application_form
          .work_histories
          .where.not(start_date: nil)
          .where.not(hours_per_week: nil)
    elsif !work_history_relation.nil? && application_form.nil?
      @work_history_relation = work_history_relation
    else
      raise "Pass only an application_form or a work_history_relation."
    end
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

  attr_reader :work_history_relation

  def work_histories
    @work_histories ||=
      work_history_relation.order(:start_date).select(
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
