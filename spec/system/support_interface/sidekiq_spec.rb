# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sidekiq support", type: :system do
  it "requires permission" do
    given_i_am_authorized_as_an_assessor_user
    when_i_visit_the_sidekiq_page
    then_i_see_the_access_denied_page
  end

  it "does not allow any any access if user is archived" do
    given_i_am_authorized_as_an_archived_support_user
    when_i_visit_the_sidekiq_page
    then_i_see_the_access_denied_page
  end

  it "allows viewing Sidekiq dashboard" do
    given_i_am_authorized_as_a_support_user
    when_i_visit_the_sidekiq_page
    then_i_see_the_sidekiq_dashboard
  end

  private

  def when_i_visit_the_sidekiq_page
    visit "/support/sidekiq"
  end

  def then_i_see_the_access_denied_page
    expect(page).to have_content("Page not found")
  end

  def then_i_see_the_sidekiq_dashboard
    expect(page).to have_current_path("/support/sidekiq")
    expect(page).to have_content("Dashboard")
    expect(page).to have_content("History")
  end
end
