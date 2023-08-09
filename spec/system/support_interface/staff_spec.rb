require "rails_helper"

RSpec.describe "Staff support", type: :system do
  before { given_the_service_is_open }

  it "requires permission" do
    given_i_am_authorized_as_an_assessor_user
    when_i_visit_the_staff_page
    then_i_see_the_forbidden_page
  end

  it "allows inviting a user with Azure active directory active" do
    given_sign_in_with_active_directory_is_active
    given_i_am_authorized_as_a_support_user
    when_i_visit_the_staff_page
    then_i_see_the_staff_index

    when_i_click_on_invite
    then_i_see_the_staff_invitation_form

    when_i_fill_email_address
    and_i_fill_name
    and_i_choose_support_console_permission
    and_i_send_invitation
    then_i_see_an_invitation_email
    then_i_see_the_staff_index
    then_i_see_the_invited_staff_user
    then_i_sign_out

    when_i_visit_the_invitation_email_with_azure_ad_enabled
    then_i_am_taken_to_the_azure_login_page
  end

  it "allows inviting a user with Azure active directory deactivated" do
    given_sign_in_with_active_directory_is_disabled
    given_i_am_authorized_as_a_support_user
    when_i_visit_the_staff_page
    then_i_see_the_staff_index

    when_i_click_on_invite
    then_i_see_the_staff_invitation_form

    when_i_fill_email_address
    and_i_fill_name
    and_i_choose_support_console_permission
    and_i_send_invitation
    then_i_see_an_invitation_email
    then_i_see_the_invited_staff_user
    then_i_sign_out

    when_i_visit_the_invitation_email_with_azure_ad_disabled
    and_i_fill_password
    and_i_set_password
    then_i_see_the_staff_index
    then_i_see_the_accepted_staff_user
  end

  it "allows editing permissions when Azure active directory is active" do
    given_sign_in_with_active_directory_is_active
    given_i_am_authorized_as_a_support_user
    given_a_helpdesk_user_exists
    when_i_visit_the_staff_page
    then_i_see_the_staff_index
    and_i_see_the_helpdesk_user

    when_i_click_on_the_helpdesk_user
    then_i_see_the_staff_edit_form
    when_i_choose_support_console_permission
    and_i_submit_the_edit_form

    then_i_see_the_changed_permission
  end

  private

  def given_a_helpdesk_user_exists
    create(:staff, :confirmed, name: "Helpdesk")
  end

  def given_sign_in_with_active_directory_is_active
    FeatureFlags::FeatureFlag.activate(:sign_in_with_active_directory)
  end

  def given_sign_in_with_active_directory_is_disabled
    FeatureFlags::FeatureFlag.deactivate(:sign_in_with_active_directory)
  end

  def when_i_visit_the_staff_page
    visit support_interface_staff_index_path
  end

  def when_i_visit_the_invitation_email_with_azure_ad_enabled
    message = ActionMailer::Base.deliveries.first
    uri = URI.parse(URI.extract(message.body.encoded).second)
    expect(uri.path).to eq("/staff/auth/azure_activedirectory_v2")
    visit uri.path.to_s
  end

  def when_i_visit_the_invitation_email_with_azure_ad_disabled
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

  def and_i_choose_support_console_permission
    check "staff-support-console-permission-1-field", visible: false
  end

  def and_i_send_invitation
    click_button "Send an invitation", visible: false
  end

  def and_i_set_password
    click_button "Set my password", visible: false
  end

  def and_i_see_the_helpdesk_user
    expect(page).to have_content("Support console access\tNO")
  end

  def when_i_click_on_the_helpdesk_user
    find(:xpath, "(//a[text()='Change'])[5]").click
  end

  def then_i_see_the_staff_edit_form
    expect(page).to have_content("Edit ‘Helpdesk’")
  end

  alias_method :when_i_choose_support_console_permission,
               :and_i_choose_support_console_permission

  def and_i_submit_the_edit_form
    click_button "Continue"
  end

  def then_i_see_the_changed_permission
    expect(page).to_not have_content("Support console access\tNO")
  end

  def then_i_am_taken_to_the_azure_login_page
    expect(page.current_url).to include("https://login.microsoftonline.com/")
  end
end
