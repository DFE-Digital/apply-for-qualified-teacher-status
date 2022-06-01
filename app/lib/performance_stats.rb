class PerformanceStats
  def initialize(since, until_days)
    unless since.is_a? ActiveSupport::TimeWithZone
      raise ArgumentError, "since is not a TimeWithZone"
    end
    unless until_days.is_a? Integer
      raise ArgumentError, "until_days is not an Integer"
    end

    @eligibility_checks =
      EligibilityCheck.where(created_at: since..Time.zone.now)

    @grouped_eligibility_checks =
      @eligibility_checks.group("date_trunc('day', created_at)")

    @last_n_days = (0..until_days).map { |n| n.days.ago.beginning_of_day.utc }

    calculate_live_service_usage
    calculate_submission_results
    calculate_country_usage
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
      eligibility_checks_by_country.map do |region, count|
        [region.full_name, count]
      end

    @countries = eligibility_checks_by_country.count
  end
end
