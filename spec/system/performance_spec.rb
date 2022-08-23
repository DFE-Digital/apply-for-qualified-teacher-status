require "spec_helper"

RSpec.describe "Performance", type: :system do
  before { travel_to Date.new(2022, 6, 30) }

  after { travel_back }

  it "using the performance dashboard" do
    given_the_service_is_open
    given_there_are_a_few_eligibility_checks
    when_i_visit_the_performance_page
    then_i_see_the_live_stats

    when_i_visit_the_performance_page_since_launch
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

  def when_i_visit_the_performance_page
    visit performance_path
  end

  def then_i_see_the_live_stats
    expect(page).to have_content("36\nchecks over the last 7 days")
    expect(page).to have_content("30 June\t1")
    expect(page).to have_content("24 June\t7")
  end

  def when_i_visit_the_performance_page_since_launch
    visit performance_path(since_launch: true)
  end

  def then_i_see_the_live_stats_since_launch
    expect(page).to have_content("45\nchecks since launch")
    expect(page).to have_content("30 June\t1")
    expect(page).to have_content("22 June\t9")
  end
end
