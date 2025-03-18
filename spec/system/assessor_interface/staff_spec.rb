# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Staff assessor", type: :system do
  it "requires permission" do
    given_i_am_authorized_as_an_assessor_user
    when_i_visit_the_staff_page
    then_i_see_the_forbidden_page
  end

  it "does not allow any any access if user is archived" do
    given_i_am_authorized_as_an_archived_support_user
    when_i_visit_the_staff_page
    then_i_see_the_forbidden_page
  end

  it "allows inviting a user with Azure active directory active" do
    given_sign_in_with_active_directory_is_active
    given_i_am_authorized_as_a_manage_staff_user
    when_i_visit_the_staff_page
    then_i_see_the_staff_index

    when_i_click_on_invite
    then_i_see_the_staff_invitation_form

    when_i_fill_email_address
    and_i_fill_name
    then_i_choose_manage_staff_permission
    and_i_send_invitation
    then_i_see_an_invitation_email
    then_i_see_the_staff_index
    then_i_see_the_invited_staff_user
    then_i_sign_out

    when_i_visit_the_invitation_email_with_azure_ad_enabled_i_see_the_link_to_access
  end

  it "allows inviting a user with Azure active directory deactivated" do
    given_sign_in_with_active_directory_is_disabled
    given_i_am_authorized_as_a_manage_staff_user
    when_i_visit_the_staff_page
    then_i_see_the_staff_index

    when_i_click_on_invite
    then_i_see_the_staff_invitation_form

    when_i_fill_email_address
    and_i_fill_name
    then_i_choose_manage_staff_permission
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
    given_i_am_authorized_as_a_manage_staff_user
    given_a_helpdesk_user_exists
    when_i_visit_the_staff_page
    then_i_see_the_staff_index
    and_i_see_the_helpdesk_user

    when_i_click_on_the_helpdesk_user
    then_i_see_the_staff_edit_form
    then_i_choose_manage_staff_permission
    and_i_submit_the_edit_form

    then_i_see_the_changed_permission
  end

  private

  def given_a_helpdesk_user_exists
    create(:staff, name: "Helpdesk")
  end

  def given_sign_in_with_active_directory_is_active
    FeatureFlags::FeatureFlag.activate(:sign_in_with_active_directory)
  end

  def given_sign_in_with_active_directory_is_disabled
    FeatureFlags::FeatureFlag.deactivate(:sign_in_with_active_directory)
  end

  def when_i_visit_the_staff_page
    visit assessor_interface_staff_index_path
  end

  def when_i_visit_the_invitation_email_with_azure_ad_enabled_i_see_the_link_to_access
    message = ActionMailer::Base.deliveries.first
    uri = URI.parse(URI.extract(message.body.raw_source).second)
    expect(uri.path).to eq("/staff/auth/entra_id")
  end

  def when_i_visit_the_invitation_email_with_azure_ad_disabled
    message = ActionMailer::Base.deliveries.first
    uri = URI.parse(URI.extract(message.body.raw_source).second)
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
    expect(page).to have_current_path("/assessor/staff")
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
    expect(message).not_to be_nil

    expect(message.subject).to eq("Invitation instructions")
    expect(message.to).to include("test@example.com")
  end

  def then_i_see_the_invited_staff_user
    expect(page).to have_content("test@example.com")
    expect(page).to have_content("Not accepted")
  end

  def then_i_see_the_accepted_staff_user
    expect(page).to have_content("test@example.com")
    expect(page).to have_content("Accepted")
  end

  def and_i_fill_name
    fill_in "staff-name-field", with: "Name"
  end

  def and_i_fill_password
    fill_in "staff-password-field", with: "password"
    fill_in "staff-password-confirmation-field", with: "password"
  end

  def then_i_choose_manage_staff_permission
    check "staff-manage-staff-permission-1-field", visible: false
  end

  def and_i_send_invitation
    click_button "Send an invitation", visible: false
  end

  def and_i_set_password
    click_button "Set my password", visible: false
  end

  def and_i_see_the_helpdesk_user
    expect(page).to have_content("Manage staff\nNo\tNo\tNo\tNo\tNo\tNo\tNo\tNo")
  end

  def when_i_click_on_the_helpdesk_user
    find(:xpath, "(//a[text()='Change permissions'])[2]").click
  end

  def then_i_see_the_staff_edit_form
    expect(page).to have_content("Edit ‘Helpdesk’")
  end

  def and_i_submit_the_edit_form
    click_button "Continue"
  end

  def then_i_see_the_changed_permission
    expect(page).to have_content("Manage staff\nNo\tNo\tNo\tNo\tNo\tNo\tNo\tYes")
  end
end
