class PagesController < ApplicationController
  def performance
    time_period = 1.week.ago.beginning_of_day..Time.zone.now
    until_days = 6
    @since_text = "over the last 7 days"

    if params.key? :since_launch
      launch_date = Date.new(2022, 6, 21).beginning_of_day
      time_period = launch_date..Time.zone.now
      until_days =
        ((Time.zone.now.beginning_of_day - time_period.first) / 1.day).to_i
      @since_text = "since launch"
    end

    stats = PerformanceStats.new(time_period, until_days)

    @checks_over_last_n_days, @live_service_data = stats.live_service_usage

    @eligible_checks, @submission_data = stats.submission_results

    @countries, @country_data = stats.country_usage
  end

  def current_namespace
    "pages"
  end
end
