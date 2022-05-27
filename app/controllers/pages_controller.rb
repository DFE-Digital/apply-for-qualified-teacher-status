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

    eligibility_checks =
      EligibilityCheck.where(created_at: since..Time.zone.now).group(
        "date_trunc('day', created_at)"
      )

    eligibility_checks_total = eligibility_checks.count

    eligibility_checks_eligible = eligibility_checks.eligible.count

    last_n_days = (0..until_days).map { |n| n.days.ago.beginning_of_day.utc }

    @checks_over_last_n_days = eligibility_checks_total.values.sum

    @live_service_data = [%w[Date Requests]]
    @live_service_data +=
      last_n_days.map do |day|
        [day.strftime("%d %B"), eligibility_checks_total[day] || 0]
      end

    @eligible_checks = eligibility_checks_eligible.values.sum

    @submission_data = [["Date", "Successful checks"]]
    @submission_data +=
      last_n_days.map do |day|
        [day.strftime("%d %B"), eligibility_checks_eligible[day] || 0]
      end
  end
end
