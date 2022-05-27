class PagesController < ApplicationController
  def performance
    eligibility_checks =
      EligibilityCheck.where(
        created_at: 1.week.ago.beginning_of_day..Time.zone.now
      ).group("date_trunc('day', created_at)")

    eligibility_checks_total = eligibility_checks.count

    eligibility_checks_eligible = eligibility_checks.eligible.count

    last_7_days = (0..6).map { |n| n.days.ago.beginning_of_day.utc }

    @checks_over_last_7_days = eligibility_checks_total.values.sum

    @live_service_data = [%w[Date Requests]]
    @live_service_data +=
      last_7_days.map do |day|
        [day.strftime("%d %B"), eligibility_checks_total[day] || 0]
      end

    @eligible_checks = eligibility_checks_eligible.values.sum

    @submission_data = [["Date", "Successful checks"]]
    @submission_data +=
      last_7_days.map do |day|
        [day.strftime("%d %B"), eligibility_checks_eligible[day] || 0]
      end
  end
end
