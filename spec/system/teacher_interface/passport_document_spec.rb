# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher passport document", type: :system do
  before do
    given_i_am_authorized_as_a_user(teacher)
    given_an_application_form_exists
    given_malware_scanning_is_enabled
  end

  it "uploading passport document" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_passport_document_task

    when_i_click_the_passport_document_task
    then_i_see_the(:teacher_passport_expiry_date_page)

    when_i_fill_in_my_passport_expiry_date
    then_i_see_the(:teacher_upload_document_page)

    when_i_upload_a_file
    then_i_see_the(:teacher_check_document_page)

    when_i_dont_need_to_upload_another_file
    then_i_see_the(:teacher_check_passport_document_page)
    and_i_see_the_check_page_with_expiry_date_and_country_of_issue

    when_i_continue_from_check_page
    then_i_see_the(:teacher_application_page)
    and_i_see_the_completed_passport_document_task
  end

  context "when the expiry date is in the past" do
    it "navigates to interuption page and goes back to fix expiry date" do
      when_i_visit_the(:teacher_application_page)
      then_i_see_the(:teacher_application_page)
      and_i_see_the_passport_document_task

      when_i_click_the_passport_document_task
      then_i_see_the(:teacher_passport_expiry_date_page)

      when_i_fill_in_my_passport_expiry_date_that_has_expired
      then_i_see_the(:teacher_passport_expiry_date_interruption_page)

      when_i_choose_to_go_back_to_fix_my_expiry_date
      then_i_see_the(:teacher_passport_expiry_date_page)
    end

    it "navigates to interuption page and goes back to application task list" do
      when_i_visit_the(:teacher_application_page)
      then_i_see_the(:teacher_application_page)
      and_i_see_the_passport_document_task

      when_i_click_the_passport_document_task
      then_i_see_the(:teacher_passport_expiry_date_page)

      when_i_fill_in_my_passport_expiry_date_that_has_expired
      then_i_see_the(:teacher_passport_expiry_date_interruption_page)

      when_i_choose_to_go_back_application_task_list
      then_i_see_the(:teacher_application_page)
      and_i_see_content_that_my_passport_has_expired
    end
  end

  private

  def given_an_application_form_exists
    application_form
  end

  def and_i_see_the_passport_document_task
    expect(teacher_application_page.passport_document_task_item).not_to be_nil
  end

  def when_i_click_the_passport_document_task
    teacher_application_page.passport_document_task_item.click
  end

  def when_i_fill_in_my_passport_expiry_date
    teacher_passport_expiry_date_page.form.passport_expiry_date_day_field.fill_in with:
      "1"
    teacher_passport_expiry_date_page.form.passport_expiry_date_month_field.fill_in with:
      "1"
    teacher_passport_expiry_date_page.form.passport_expiry_date_year_field.fill_in with:
      2.years.from_now.year
    teacher_passport_expiry_date_page.form.passport_country_of_issue_code.fill_in with:
      "France"
    teacher_passport_expiry_date_page.form.continue_button.click
  end

  def when_i_fill_in_my_passport_expiry_date_that_has_expired
    teacher_passport_expiry_date_page.form.passport_expiry_date_day_field.fill_in with:
      "1"
    teacher_passport_expiry_date_page.form.passport_expiry_date_month_field.fill_in with:
      "1"
    teacher_passport_expiry_date_page.form.passport_expiry_date_year_field.fill_in with:
      2.years.ago.year
    teacher_passport_expiry_date_page.form.passport_country_of_issue_code.fill_in with:
      "France"
    teacher_passport_expiry_date_page.form.continue_button.click
  end

  def when_i_choose_to_go_back_to_fix_my_expiry_date
    teacher_passport_expiry_date_interruption_page
      .form
      .back_to_expiry_date_form_radio
      .choose
    teacher_passport_expiry_date_interruption_page.form.continue_button.click
  end

  def when_i_choose_to_go_back_application_task_list
    teacher_passport_expiry_date_interruption_page
      .form
      .back_to_application_task_list_radio
      .choose
    teacher_passport_expiry_date_interruption_page.form.continue_button.click
  end

  def and_i_see_content_that_my_passport_has_expired
    expect(teacher_application_page).to have_content(
      "Your passport has expired",
    )
  end

  def when_i_upload_a_file
    teacher_upload_document_page.form.original_attachment.attach_file Rails.root.join(
      file_fixture("upload.pdf"),
    )
    teacher_upload_document_page.form.continue_button.click
  end

  def when_i_dont_need_to_upload_another_file
    teacher_check_document_page.form.false_radio_item.input.click
    teacher_check_document_page.form.continue_button.click
  end

  def and_i_see_the_check_page_with_expiry_date_and_country_of_issue
    expect(teacher_check_passport_document_page.summary_list.rows.count).to eq(
      3,
    )

    expiry_date_row = teacher_check_passport_document_page.summary_list.rows[0]
    expect(expiry_date_row.key.text).to eq("Expiry date")
    expect(expiry_date_row.value.text).to eq(
      "1 January #{2.years.from_now.year}",
    )

    country_of_issue_row =
      teacher_check_passport_document_page.summary_list.rows[1]
    expect(country_of_issue_row.key.text).to eq("Country of issue")
    expect(country_of_issue_row.value.text).to eq("France")
  end

  def when_i_continue_from_check_page
    teacher_check_passport_document_page.continue_button.click
  end

  def and_i_see_the_completed_passport_document_task
    expect(
      teacher_application_page.passport_document_task_item.status_tag.text,
    ).to eq("Completed")
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        teacher:,
        requires_passport_as_identity_proof: true,
      )
  end
end
