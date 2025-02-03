# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher personal information", type: :system do
  before do
    given_i_am_authorized_as_a_user(teacher)
    given_an_application_form_exists
    given_malware_scanning_is_enabled
  end

  it "without an alternative name" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_personal_information_task

    when_i_click_the_personal_information_task
    then_i_see_the(:teacher_name_and_date_of_birth_page)

    when_i_fill_in_my_name_and_date_of_birth
    then_i_see_the(:teacher_alternative_name_page)

    when_i_dont_have_an_alternative_name
    then_i_see_the(:teacher_check_personal_information_page)
    and_i_see_the_check_page_without_an_alternative_name

    when_i_continue_from_check_page
    then_i_see_the(:teacher_application_page)
    and_i_see_the_completed_personal_information_task
  end

  it "with an alternative name" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_personal_information_task

    when_i_click_the_personal_information_task
    then_i_see_the(:teacher_name_and_date_of_birth_page)

    when_i_fill_in_my_name_and_date_of_birth
    then_i_see_the(:teacher_alternative_name_page)

    when_i_have_an_alternative_name
    then_i_see_the(:teacher_upload_document_page)

    when_i_upload_a_file
    then_i_see_the(:teacher_check_document_page)

    when_i_dont_need_to_upload_another_file
    then_i_see_the(:teacher_check_personal_information_page)
    and_i_see_the_check_page_with_an_alternative_name

    when_i_continue_from_check_page
    then_i_see_the(:teacher_application_page)
    and_i_see_the_completed_personal_information_task
  end

  private

  def given_an_application_form_exists
    application_form
  end

  def and_i_see_the_personal_information_task
    expect(
      teacher_application_page.personal_information_task_item,
    ).not_to be_nil
  end

  def when_i_click_the_personal_information_task
    teacher_application_page.personal_information_task_item.click
  end

  def when_i_fill_in_my_name_and_date_of_birth
    teacher_name_and_date_of_birth_page.form.given_names_field.fill_in with:
      "John"
    teacher_name_and_date_of_birth_page.form.family_name_field.fill_in with:
      "Smith"
    teacher_name_and_date_of_birth_page.form.date_of_birth_day_field.fill_in with:
      "1"
    teacher_name_and_date_of_birth_page.form.date_of_birth_month_field.fill_in with:
      "1"
    teacher_name_and_date_of_birth_page.form.date_of_birth_year_field.fill_in with:
      "1999"
    teacher_name_and_date_of_birth_page.form.continue_button.click
  end

  def when_i_have_an_alternative_name
    teacher_alternative_name_page.form.has_alternative_name_true_field.choose
    teacher_alternative_name_page.form.alternative_given_names_field.fill_in with:
      "Jonathan"
    teacher_alternative_name_page.form.alternative_family_name_field.fill_in with:
      "Smithe"
    teacher_alternative_name_page.form.continue_button.click
  end

  def when_i_dont_have_an_alternative_name
    teacher_alternative_name_page.form.has_alternative_name_false_field.choose
    teacher_alternative_name_page.form.continue_button.click
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

  def and_i_see_the_check_page_with_an_alternative_name
    expect(
      teacher_check_personal_information_page.summary_list.rows.count,
    ).to eq(7)

    given_names_row =
      teacher_check_personal_information_page.summary_list.rows[0]
    expect(given_names_row.key.text).to eq("Given names")
    expect(given_names_row.value.text).to eq("John")

    family_name_row =
      teacher_check_personal_information_page.summary_list.rows[1]
    expect(family_name_row.key.text).to eq("Surname")
    expect(family_name_row.value.text).to eq("Smith")

    date_of_birth_row =
      teacher_check_personal_information_page.summary_list.rows[2]
    expect(date_of_birth_row.key.text).to eq("Date of birth")
    expect(date_of_birth_row.value.text).to eq("1 January 1999")

    has_alternative_name_row =
      teacher_check_personal_information_page.summary_list.rows[3]
    expect(has_alternative_name_row.key.text).to eq(
      "Name appears differently on your passport or qualifications?",
    )
    expect(has_alternative_name_row.value.text).to eq("Yes")

    alternative_given_names_row =
      teacher_check_personal_information_page.summary_list.rows[4]
    expect(alternative_given_names_row.key.text).to eq("Alternate given names")
    expect(alternative_given_names_row.value.text).to eq("Jonathan")

    alternative_family_name_row =
      teacher_check_personal_information_page.summary_list.rows[5]
    expect(alternative_family_name_row.key.text).to eq("Alternate surname")
    expect(alternative_family_name_row.value.text).to eq("Smithe")

    name_change_document_row =
      teacher_check_personal_information_page.summary_list.rows[6]
    expect(name_change_document_row.key.text).to eq("Name change document")
    expect(name_change_document_row.value.text).to eq(
      "upload.pdf (opens in new tab)",
    )
  end

  def and_i_see_the_check_page_without_an_alternative_name
    expect(
      teacher_check_personal_information_page.summary_list.rows.count,
    ).to eq(4)

    given_names_row =
      teacher_check_personal_information_page.summary_list.rows.first
    expect(given_names_row.key.text).to eq("Given names")
    expect(given_names_row.value.text).to eq("John")

    family_name_row =
      teacher_check_personal_information_page.summary_list.rows.second
    expect(family_name_row.key.text).to eq("Surname")
    expect(family_name_row.value.text).to eq("Smith")

    date_of_birth_row =
      teacher_check_personal_information_page.summary_list.rows.third
    expect(date_of_birth_row.key.text).to eq("Date of birth")
    expect(date_of_birth_row.value.text).to eq("1 January 1999")

    has_alternative_name_row =
      teacher_check_personal_information_page.summary_list.rows.fourth
    expect(has_alternative_name_row.key.text).to eq(
      "Name appears differently on your passport or qualifications?",
    )
    expect(has_alternative_name_row.value.text).to eq("No")
  end

  def when_i_continue_from_check_page
    teacher_check_personal_information_page.continue_button.click
  end

  def and_i_see_the_completed_personal_information_task
    expect(
      teacher_application_page.personal_information_task_item.status_tag.text,
    ).to eq("Completed")
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def application_form
    @application_form ||= create(:application_form, teacher:)
  end
end
