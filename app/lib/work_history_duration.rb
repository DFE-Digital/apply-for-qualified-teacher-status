# frozen_string_literal: true

class WorkHistoryDuration
  def initialize(
    application_form:,
    relation:,
    consider_teaching_qualification: false
  )
    @application_form = application_form
    @relation =
      relation.where.not(start_date: nil).where.not(hours_per_week: nil)
    @consider_teaching_qualification = consider_teaching_qualification
  end

  def self.for_application_form(
    application_form,
    consider_teaching_qualification: false
  )
    WorkHistoryDuration.new(
      application_form:,
      relation: application_form.work_histories,
      consider_teaching_qualification:,
    )
  end

  def self.for_ids(
    ids,
    application_form:,
    consider_teaching_qualification: false
  )
    WorkHistoryDuration.new(
      application_form:,
      relation: application_form.work_histories.where(id: ids),
      consider_teaching_qualification:,
    )
  end

  def self.for_record(record, consider_teaching_qualification: false)
    for_ids(
      [record.id],
      application_form: record.application_form,
      consider_teaching_qualification:,
    )
  end

  def count_months
    @count_months ||=
      work_histories
        .map { |work_history| work_history_full_time_months(work_history) }
        .sum
        .round
  end

  def count_years_and_months
    if count_months <= 24
      [0, count_months]
    else
      years_count = (count_months / 12).floor
      remaining_months_count = count_months - years_count * 12
      [years_count, remaining_months_count]
    end
  end

  def enough_for_submission?
    count_months >= THRESHOLD_MONTHS_FOR_SUBMISSION
  end

  def enough_to_skip_induction?
    count_months >= THRESHOLD_MONTHS_TO_SKIP_INDUCTION
  end

  private

  THRESHOLD_MONTHS_FOR_SUBMISSION = 9
  THRESHOLD_MONTHS_TO_SKIP_INDUCTION = 20

  AVERAGE_WEEKS_PER_MONTH = 4.34
  HOURS_PER_FULL_TIME_MONTH = 130.0

  attr_reader :application_form, :relation, :consider_teaching_qualification

  def work_histories
    @work_histories ||=
      relation.order(:start_date).select(
        :start_date,
        :end_date,
        :hours_per_week,
      )
  end

  def teaching_qualification
    @teaching_qualification ||=
      if consider_teaching_qualification
        application_form.teaching_qualification
      end
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
    start = date_first_of_month(work_history_start_date(work_history))
    finish = date_first_of_month(work_history_end_date(work_history))

    date_range(start..finish).every(months: 1).count
  end

  def work_history_start_date(work_history)
    [
      work_history.start_date,
      teaching_qualification&.certificate_date,
    ].compact.max
  end

  def work_history_end_date(work_history)
    work_history.end_date || Time.zone.today
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
