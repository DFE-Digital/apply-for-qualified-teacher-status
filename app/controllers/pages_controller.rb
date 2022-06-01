class PagesController < ApplicationController
  def performance
    since = 1.week.ago.beginning_of_day
    until_days = 6
    @since_text = "over the last 7 days"

    if params.key? :since_launch
      launch_date = Date.new(2022, 6, 1).beginning_of_day
      since = launch_date
      until_days = ((Time.zone.now.beginning_of_day - since) / (3600 * 24)).to_i
      @since_text = "since launch"
    end

    stats = PerformanceStats.new(since, until_days)

    @checks_over_last_n_days, @live_service_data = stats.live_service_usage

    @eligible_checks, @submission_data = stats.submission_results

    @countries, @country_data = stats.country_usage
  end
end
