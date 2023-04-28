require "rails_helper"

RSpec.describe "Performance", type: :system do
  before do
    travel_to Date.new(2022, 6, 30)

    given_the_service_is_open
    given_there_are_a_few_eligibility_checks
  end

  after { travel_back }

  it "usage stats" do
    when_i_visit_the(:performance_page)
    then_i_see_the_live_stats
  end

  it "usage stats since launch" do
    when_i_visit_the(:performance_page, since_launch: true)
    then_i_see_the_live_stats_since_launch
  end

  private

  def given_there_are_a_few_eligibility_checks
    (0..8).each.with_index do |n, i|
      (i + 1).times do
        create(:eligibility_check, :eligible, created_at: n.days.ago)
      end
    end
  end

  def then_i_see_the_live_stats
    expect(performance_page.live_service_usage.stats.first).to have_content(
      "36\nchecks over the last 7 days",
    )
    expect(performance_page.live_service_usage.table).to have_content(
      "30 June\t1",
    )
    expect(performance_page.live_service_usage.table).to have_content(
      "24 June\t7",
    )
  end

  def then_i_see_the_live_stats_since_launch
    expect(performance_page.live_service_usage.stats.first).to have_content(
      "45\nchecks since launch",
    )
    expect(performance_page.live_service_usage.table).to have_content(
      "30 June\t1",
    )
    expect(performance_page.live_service_usage.table).to have_content(
      "22 June\t9",
    )
  end
end
