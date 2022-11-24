require "rails_helper"

RSpec.describe "Staff support", type: :system do
  it "allows inviting a user" do
    given_the_service_is_open
    given_i_am_authorized_as_a_support_user
    when_i_visit_the_staff_page
    then_i_see_the_staff_index

    when_i_click_on_invite
    then_i_see_the_staff_invitation_form

    when_i_fill_email_address
    and_i_fill_name
    and_i_send_invitation
    then_i_see_an_invitation_email
    then_i_see_the_staff_index
    then_i_see_the_invited_staff_user
    then_i_sign_out

    when_i_visit_the_invitation_email
    and_i_fill_password
    and_i_set_password
    then_i_see_the_staff_index

    then_i_see_the_accepted_staff_user
  end

  private

  def when_i_visit_the_staff_page
    visit support_interface_staff_index_path
  end

  def when_i_visit_the_invitation_email
    message = ActionMailer::Base.deliveries.first
    uri = URI.parse(URI.extract(message.body.encoded).second)
    expect(uri.path).to eq("/staff/invitation/accept")
    expect(uri.query).to include("invitation_token=")
    visit "#{uri.path}?#{uri.query}"
  end

  def when_i_click_on_invite
    click_link "Invite"
  end

  def when_i_fill_email_address
    fill_in "staff-email-field", with: "test@example.com"
  end

  def then_i_see_the_staff_index
    expect(page).to have_current_path("/support/staff")
    expect(page).to have_title("Staff")
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

  def then_i_see_the_invited_staff_user
    expect(page).to have_content("test@example.com")
    expect(page).to have_content("NOT ACCEPTED")
  end

  def then_i_see_the_accepted_staff_user
    expect(page).to have_content("test@example.com")
    expect(page).to have_content("ACCEPTED")
  end

  def and_i_fill_name
    fill_in "staff-name-field", with: "Name"
  end

  def and_i_fill_password
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
