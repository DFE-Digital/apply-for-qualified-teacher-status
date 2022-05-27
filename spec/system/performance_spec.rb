require "rails_helper"

RSpec.describe "Performance", type: :system do
  before { travel_to Date.new(2022, 4, 21) }

  after { travel_back }

  it "using the performance dashboard" do
    given_the_service_is_open
    given_there_are_a_few_eligibility_checks
    when_i_visit_the_performance_page
    then_i_see_the_live_stats
  end

  private

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def given_there_are_a_few_eligibility_checks
    (0..6).each.with_index do |n, i|
      (i + 1).times do
        create(:eligibility_check, :eligible, created_at: n.days.ago)
      end
    end
  end

  def when_i_visit_the_performance_page
    visit performance_path
  end

  def then_i_see_the_live_stats
    expect(page).to have_content("28\neligibility checks over the last 7 days")
    expect(page).to have_content("21 April\t1")
    expect(page).to have_content("15 April\t7")
  end
end
