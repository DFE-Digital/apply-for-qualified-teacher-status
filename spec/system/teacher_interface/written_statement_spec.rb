# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher written statement", type: :system do
  before do
    given_i_am_authorized_as_a_user(teacher)
    given_an_application_form_exists
    given_malware_scanning_is_enabled
  end

  it "teacher provides document" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_upload_written_statement_task

    when_i_click_the_upload_written_statement_task
    then_i_see_the(:teacher_upload_document_page)

    when_i_upload_a_file
    then_i_see_the(:teacher_check_document_page)

    when_i_dont_need_to_upload_another_file
    then_i_see_the(:teacher_application_page)
    and_i_see_the_upload_written_statement_task_is_completed
  end

  it "teaching authority provides document" do
    given_the_teaching_authority_provides_written_statement

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_provide_written_statement_task

    when_i_click_the_provide_written_statement_task
    then_i_see_the(:teacher_edit_written_statement_page)

    when_i_confirm_written_statement
    then_i_see_the(:teacher_application_page)
    and_i_see_the_provide_written_statement_task_is_completed
  end

  it "teacher doesn't have document" do
    given_the_written_statement_is_optional

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_upload_written_statement_task

    when_i_click_the_upload_written_statement_task
    then_i_see_the(:teacher_document_available_page)

    when_i_dont_have_the_document
    then_i_see_the(:teacher_application_page)
    and_i_see_the_upload_written_statement_task_is_completed
  end

  private

  def given_an_application_form_exists
    application_form
  end

  def given_the_teaching_authority_provides_written_statement
    application_form.update!(
      teaching_authority_provides_written_statement: true,
    )
  end

  def given_the_written_statement_is_optional
    application_form.update!(written_statement_optional: true)
  end

  def and_i_see_the_upload_written_statement_task
    expect(
      teacher_application_page.upload_written_statement_task_item,
    ).to_not be_nil
  end

  def when_i_click_the_upload_written_statement_task
    teacher_application_page.upload_written_statement_task_item.click
  end

  def when_i_upload_a_file
    teacher_upload_document_page.form.original_attachment.attach_file Rails.root.join(
      file_fixture("upload.pdf"),
    )
    teacher_upload_document_page.form.written_in_english_items.first.choose
    teacher_upload_document_page.form.continue_button.click
  end

  def when_i_dont_have_the_document
    teacher_document_available_page.form.false_radio_item.choose
    teacher_document_available_page.form.continue_button.click
  end

  def when_i_dont_need_to_upload_another_file
    teacher_check_document_page.form.false_radio_item.input.click
    teacher_check_document_page.form.continue_button.click
  end

  def and_i_see_the_upload_written_statement_task_is_completed
    expect(
      teacher_application_page
        .upload_written_statement_task_item
        .status_tag
        .text,
    ).to eq("COMPLETED")
  end

  def and_i_see_the_provide_written_statement_task
    expect(
      teacher_application_page.provide_written_statement_task_item,
    ).to_not be_nil
  end

  def when_i_click_the_provide_written_statement_task
    teacher_application_page.provide_written_statement_task_item.click
  end

  def when_i_confirm_written_statement
    teacher_edit_written_statement_page
      .form
      .written_statement_confirmation_checkbox
      .click
    teacher_edit_written_statement_page.form.continue_button.click
  end

  def and_i_see_the_provide_written_statement_task_is_completed
    expect(
      teacher_application_page
        .provide_written_statement_task_item
        .status_tag
        .text,
    ).to eq("COMPLETED")
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        teacher:,
        region:
          create(:region, :written_checks, :in_country, country_code: "GB-NIR"),
      )
  end
end
