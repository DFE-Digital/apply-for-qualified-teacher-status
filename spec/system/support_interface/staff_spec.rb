require "rails_helper"

RSpec.describe "Staff support", type: :system do
  it "index" do
    when_i_am_authorized_as_a_support_user
    when_i_visit_the_staff_page
    then_i_see_the_staff
  end

private

  def when_i_am_authorized_as_a_support_user
    page.driver.basic_authorize(
      ENV.fetch("SUPPORT_USERNAME", "test"),
      ENV.fetch("SUPPORT_PASSWORD", "test")
    )
  end

  def when_i_visit_the_staff_page
    visit support_interface_staff_index_path
  end

  def then_i_see_the_staff
    expect(page).to have_current_path("/support/staff")
    expect(page).to have_title("Staff")
  end
end
