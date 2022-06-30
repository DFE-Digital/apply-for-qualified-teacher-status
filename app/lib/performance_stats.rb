class PerformanceStats
  def initialize(from: 1.week.ago.beginning_of_day, to: Time.zone.now)
    time_period = from..to

    number_of_days_in_period = ((to.beginning_of_day - from) / 1.day).to_i
    @eligibility_checks = EligibilityCheck.where(created_at: time_period)

    @grouped_eligibility_checks =
      @eligibility_checks.group("date_trunc('day', created_at)")

    @last_n_days =
      (0...number_of_days_in_period).map { |n| n.days.ago.beginning_of_day.utc }

    calculate_live_service_usage
    calculate_submission_results
    calculate_country_usage
    calculate_duration_usage
  end

  def live_service_usage
    [@checks_over_last_n_days, @live_service_data]
  end

  def submission_results
    [@eligible_checks, @submission_data]
  end

  def country_usage
    [@countries, @country_data]
  end

  def duration_usage
    @duration_data
  end

  private

  def calculate_live_service_usage
    eligibility_checks_total = @grouped_eligibility_checks.count

    @checks_over_last_n_days = eligibility_checks_total.values.sum

    @live_service_data = [%w[Date Requests]]
    @live_service_data +=
      @last_n_days.map do |day|
        [day.strftime("%d %B"), eligibility_checks_total[day] || 0]
      end
  end

  def calculate_submission_results
    eligibility_checks_eligible = @grouped_eligibility_checks.eligible.count
    @eligible_checks = eligibility_checks_eligible.values.sum

    @submission_data = [["Date", "Successful checks"]]
    @submission_data +=
      @last_n_days.map do |day|
        [day.strftime("%d %B"), eligibility_checks_eligible[day] || 0]
      end
  end

  def calculate_country_usage
    eligibility_checks_by_country =
      @eligibility_checks.group("region").where.not(region: nil).count

    @country_data = [%w[Country Requests]]
    @country_data +=
      eligibility_checks_by_country
        .sort_by { |region, count| [count, region.name, region.country.name] }
        .group_by { |region, _| region.country }
        .map do |country, regions_and_counts|
          [country.name, regions_and_counts.sum(&:second)]
        end

    @countries = eligibility_checks_by_country.count
  end

  def calculate_duration_usage
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

    @duration_data = [
      [
        "Date",
        "90% of users within",
        "75% of users within",
        "50% of users within"
      ]
    ]
    @duration_data +=
      @last_n_days.map do |day|
        percentiles = percentiles_by_day[day] || [0, 0, 0]
        [day.strftime("%d %B")] +
          percentiles.map do |value|
            ActiveSupport::Duration.build(value.to_i).inspect
          end
      end
  end
end
