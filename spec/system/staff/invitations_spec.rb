require "rails_helper"

RSpec.describe "Staff invitations", type: :system do
  it "allows inviting staff members" do
    given_the_service_is_startable

    when_i_am_authorized_as_a_support_user
    when_i_visit_the_staff_invitation_page
    then_i_see_the_staff_invitation_form

    when_i_fill_email_address
    and_i_send_invitation

    then_i_see_an_invitation_email

    when_i_am_not_authorized_as_a_support_user
    when_i_visit_the_invitation_email

    when_i_fill_password
    and_i_set_password

    then_i_am_taken_to_support_interface
  end

  private

  def given_the_service_is_startable
    FeatureFlag.activate(:service_start)
  end

  def when_i_am_authorized_as_a_support_user
    page.driver.basic_authorize(
      ENV.fetch("SUPPORT_USERNAME", "test"),
      ENV.fetch("SUPPORT_PASSWORD", "test")
    )
  end

  def when_i_am_not_authorized_as_a_support_user
    page.driver.open_new_window
  end

  def when_i_visit_the_staff_invitation_page
    visit new_staff_invitation_path
  end

  def when_i_visit_the_invitation_email
    message = ActionMailer::Base.deliveries.first
    uri = URI.parse(URI.extract(message.body.to_s).second)
    expect(uri.path).to eq("/staff/invitation/accept")
    expect(uri.query).to include("invitation_token=")
    visit "#{uri.path}?#{uri.query}"
  end

  def then_i_see_the_staff_invitation_form
    expect(page).to have_current_path("/staff/invitation/new")
    expect(page).to have_content("Send invitation")
    expect(page).to have_content("Email")
    expect(page).to have_content("Send an invitation")
  end

  def then_i_see_an_invitation_email
    message = ActionMailer::Base.deliveries.first
    expect(message).to_not be_nil

    expect(message.subject).to eq("Invitation instructions")
    expect(message.to).to include("test@example.com")
  end

  def then_i_am_taken_to_support_interface
    expect(page).to have_current_path("/support/features")
  end

  def when_i_fill_email_address
    fill_in "staff-email-field", with: "test@example.com"
  end

  def when_i_fill_password
    fill_in "staff-password-field", with: "password"
    fill_in "staff-password-confirmation-field", with: "password"
  end

  def and_i_send_invitation
    click_button "Send an invitation", visible: false
  end

  def and_i_set_password
    click_button "Set my password", visible: false
  end
end
