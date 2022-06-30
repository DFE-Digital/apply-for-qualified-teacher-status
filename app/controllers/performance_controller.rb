class PerformanceController < ApplicationController
  def index
    from = 1.week.ago.beginning_of_day
    @since_text = "over the last 7 days"

    if params.key? :since_launch
      launch_date = Date.new(2022, 6, 21).beginning_of_day
      from = launch_date
      @since_text = "since launch"
    end

    stats = PerformanceStats.new(from:)

    @all_checks_count, @eligible_checks_count, @live_service_data =
      stats.live_service_usage
    @time_to_complete_data = stats.time_to_complete
    @countries, @country_data = stats.country_usage
  end

  def current_namespace
    "performance"
  end
end
