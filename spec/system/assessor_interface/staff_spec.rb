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

  it "allows archived user to only appear on archived users tab" do
    given_i_am_authorized_as_a_manage_staff_user
    given_a_archived_user_exists
    when_i_visit_the_staff_page
    then_i_see_the_staff_index
    and_i_do_not_see_the_archived_user

    when_i_click_on_archived
    then_i_see_the_archived_user
  end

  it "allows user to be archived with archive button" do
    given_i_am_authorized_as_a_manage_staff_user
    given_a_archived_user_exists
    given_user_zack_exists
    when_i_visit_the_staff_page
    then_i_see_the_staff_index
    and_i_see_the_archive_user_button

    when_i_click_the_archive_user_button
    then_i_see_the_edit_archive_page
    when_i_click_on_no
    then_i_see_the_staff_index

    when_i_click_the_archive_user_button
    then_i_see_the_edit_archive_page
    when_i_click_on_yes_archive
    then_i_see_the_user_zack
    and_zack_is_at_the_top_of_the_list_of_users
    and_i_see_the_archive_success_message
  end

  it "allows user to be unarchived with reactivate button" do
    given_i_am_authorized_as_a_manage_staff_user
    given_user_sam_exists
    given_a_helpdesk_user_exists

    when_i_click_the_archived_users_tab
    then_i_see_the_reactivate_user_button
    when_i_click_the_reactivate_user_button
    then_i_see_the_edit_unarchive_page

    when_i_click_on_no
    then_i_see_the_reactivate_user_button

    when_i_click_the_reactivate_user_button
    then_i_see_the_edit_unarchive_page
    when_i_click_on_yes_reactivate
    then_i_see_the_user_sam
    and_i_see_the_reactivate_success_message
    and_sam_is_at_the_top_of_the_list_of_users
  end

  private

  def given_a_helpdesk_user_exists
    create(:staff, name: "Helpdesk")
  end

  def given_a_archived_user_exists
    create(:staff, name: "ArchivedUser", archived: true, updated_at: 1.day.ago)
  end

  def given_user_zack_exists
    create(:staff, name: "Zack", updated_at: 1.day.ago)
  end

  def given_user_sam_exists
    create(:staff, name: "Sam", archived: true)
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

  def when_i_click_on_archived
    click_link "Archived users"
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
    expect(page).to have_content("Last signed in\t\t")
  end

  def then_i_see_the_accepted_staff_user
    expect(page).to have_content("test@example.com")
    expect(page.text).to match(/Last signed in.*#{Time.zone.now.year}/)
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

  def then_i_see_the_archived_user
    expect(page).to have_content("ArchivedUser")
  end

  def and_i_do_not_see_the_archived_user
    expect(page).not_to have_content("ArchivedUser")
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
    expect(page).to have_content(
      "Manage staff\nNo\tNo\tNo\tNo\tNo\tNo\tNo\tYes",
    )
  end

  def and_i_see_the_archive_user_button
    expect(page).to have_content("Archive user")
  end

  def when_i_click_the_archive_user_button
    find(:xpath, "(//a[text()='Archive user'])[2]").click
  end

  def then_i_see_the_edit_archive_page
    expect(page).to have_content("Are you sure you want to archive the user")
  end

  def when_i_click_on_no
    assessor_staff_archive_page.cancel_link.click
  end

  def when_i_click_on_yes_archive
    assessor_staff_archive_page.archive_button.click
  end

  def when_i_click_on_yes_reactivate
    assessor_staff_unarchive_page.reactivate_button.click
  end

  def then_i_see_the_user_zack
    expect(page).to have_content("Zack")
  end

  def and_zack_is_at_the_top_of_the_list_of_users
    first_staff_heading =
      find(:xpath, '//*[@id="archived-users"]/div[1]/div[1]/h2')
    expect(first_staff_heading).to have_content("Zack")
  end

  def and_sam_is_at_the_top_of_the_list_of_users
    first_staff_heading =
      find(:xpath, '//*[@id="active-users"]/div[1]/div[1]/h2')
    expect(first_staff_heading).to have_content("Sam")
  end

  def and_i_see_the_archive_success_message
    success_message = find(:xpath, '//*[@id="main-content"]/div[1]/div[2]/p')
    expect(success_message).to have_content("Zack has been archived")
  end

  def and_i_see_the_reactivate_success_message
    success_message = find(:xpath, '//*[@id="main-content"]/div[1]/div[2]/p')
    expect(success_message).to have_content("Sam has been reactivated")
  end

  def when_i_click_the_archived_users_tab
    visit assessor_interface_staff_index_path
    assessor_staff_index_page.archived_users_tab.click
  end

  def then_i_see_the_reactivate_user_button
    expect(page).to have_content("Reactivate user")
  end

  def when_i_click_the_reactivate_user_button
    find(:xpath, '//*[@id="archived-users"]/div[1]/div[2]/a').click
  end

  def then_i_see_the_edit_unarchive_page
    expect(page).to have_content("Are you sure you want to reactivate the user")
  end

  def then_i_see_the_user_sam
    expect(page).to have_content("Sam")
  end
end
