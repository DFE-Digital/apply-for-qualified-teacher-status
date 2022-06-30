class PerformanceStats
  include ActionView::Helpers::NumberHelper

  def initialize(from: 1.week.ago.beginning_of_day, to: Time.zone.now)
    time_period = from..to

    number_of_days_in_period = ((to.beginning_of_day - from) / 1.day).to_i
    @eligibility_checks = EligibilityCheck.where(created_at: time_period)

    @grouped_eligibility_checks =
      @eligibility_checks.group("date_trunc('day', created_at)")

    @last_n_days =
      (0...number_of_days_in_period).map { |n| n.days.ago.beginning_of_day.utc }

    calculate_live_service_usage
    calculate_time_to_complete
    calculate_usage_by_country
  end

  def live_service_usage
    [@all_checks_count, @eligible_checks_count, @live_service_data]
  end

  def time_to_complete
    @time_to_complete_data
  end

  def usage_by_country
    [@usage_by_country_count, @usage_by_country_data]
  end

  private

  def calculate_live_service_usage
    eligibility_checks_all = @grouped_eligibility_checks.count
    eligibility_checks_eligible = @grouped_eligibility_checks.eligible.count

    @all_checks_count = eligibility_checks_all.values.sum
    @eligible_checks_count = eligibility_checks_eligible.values.sum

    @live_service_data = [
      ["Date", "All checks", "Eligible checks", "Proportion eligible"]
    ]
    @live_service_data +=
      @last_n_days.map do |day|
        all_checks = eligibility_checks_all[day] || 0
        eligible_checks = eligibility_checks_eligible[day] || 0
        conversion = all_checks != 0 ? eligible_checks / all_checks : 0
        [
          day.strftime("%d %B"),
          all_checks,
          eligible_checks,
          number_to_percentage(conversion * 100, precision: 0)
        ]
      end
  end

  def calculate_time_to_complete
    percentiles_by_day =
      @eligibility_checks
        .complete
        .answered_all_questions
        .group("1")
        .pluck(
          Arel.sql("date_trunc('day', created_at) AS day"),
          Arel.sql(
            "percentile_cont(0.90) within group (order by (completed_at - created_at) asc) as percentile_90"
          ),
          Arel.sql(
            "percentile_cont(0.75) within group (order by (completed_at - created_at) asc) as percentile_75"
          ),
          Arel.sql(
            "percentile_cont(0.50) within group (order by (completed_at - created_at) asc) as percentile_50"
          )
        )
        .each_with_object({}) { |row, hash| hash[row[0]] = row.slice(1, 3) }

    @time_to_complete_data = [
      [
        "Date",
        "90% of users within",
        "75% of users within",
        "50% of users within"
      ]
    ]
    @time_to_complete_data +=
      @last_n_days.map do |day|
        percentiles = percentiles_by_day[day] || [0, 0, 0]
        [day.strftime("%d %B")] +
          percentiles.map do |value|
            ActiveSupport::Duration.build(value.to_i).inspect
          end
      end
  end

  def calculate_usage_by_country
    eligibility_checks_by_region =
      @eligibility_checks
        .includes(region: :country)
        .where.not(region: nil)
        .group(:region)
        .count

    @usage_by_country_count = eligibility_checks_by_region.count

    @usage_by_country_data = [%w[Country State Checks]]
    @usage_by_country_data +=
      eligibility_checks_by_region
        .sort_by { |region, count| [-count, region.country.name, region.name] }
        .map { |region, count| [region.country.name, region.name, count] }
  end
end
y
