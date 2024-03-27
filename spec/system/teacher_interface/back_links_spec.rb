# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher back links", type: :system do
  before do
    given_i_am_authorized_as_a_user(teacher)
    given_an_application_form_exists
    given_malware_scanning_is_enabled
  end

  it "back links follow user" do
    # teacher_application_page -> teacher_new_qualification_page
    #  <- teacher_application_page

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)

    when_i_click_qualifications
    then_i_see_the(:teacher_new_qualification_page)

    when_i_click_back
    then_i_see_the(:teacher_application_page)

    # teacher_application_page -> new_qualification_page -> upload_document_page
    #  <- teacher_edit_qualification_page <- teacher_application_page

    when_i_click_qualifications
    and_i_fill_in_qualification
    then_i_see_the(:teacher_upload_document_page)

    when_i_click_back
    then_i_see_the(
      :teacher_edit_qualification_page,
      qualification_id: qualification.id,
    )

    when_i_click_back
    then_i_see_the(:teacher_application_page)

    # teacher_application_page -> teacher_edit_qualification_page -> upload_document_page -> document_form_page
    #  <- teacher_edit_qualification_page

    when_i_click_qualifications
    and_i_click_continue
    then_i_see_the(:teacher_upload_document_page)

    when_i_upload_a_document
    then_i_see_the(:teacher_check_document_page)

    when_i_click_back
    then_i_see_the(
      :teacher_edit_qualification_page,
      qualification_id: qualification.id,
    )

    # teacher_edit_qualification_page -> document_form_page -> upload_document_page -> document_form_page
    #  -> teacher_part_of_degree_page
    #  <- document_form_page <- document_form_page <- teacher_edit_qualification_page

    when_i_click_continue
    then_i_see_the(:teacher_check_document_page)

    when_i_dont_upload_another_document
    then_i_see_the(:teacher_upload_document_page)

    when_i_upload_a_document
    then_i_see_the(:teacher_check_document_page)

    when_i_dont_upload_another_document
    then_i_see_the(:teacher_teaching_qualification_part_of_degree_page)

    when_i_click_back
    then_i_see_the(:teacher_check_document_page)

    when_i_click_back
    then_i_see_the(:teacher_check_document_page)

    when_i_click_back
    then_i_see_the(
      :teacher_edit_qualification_page,
      qualification_id: qualification.id,
    )

    # teacher_edit_qualification_page -> document_form_page -> document_form_page
    #  -> teacher_part_of_degree_page -> teacher_check_qualification_page
    #  <- teacher_application_page

    when_i_click_continue
    then_i_see_the(:teacher_check_document_page)

    when_i_dont_upload_another_document
    then_i_see_the(:teacher_check_document_page)

    when_i_dont_upload_another_document
    then_i_see_the(:teacher_teaching_qualification_part_of_degree_page)

    when_i_choose_part_of_degree
    then_i_see_the(:teacher_check_qualification_page)

    when_i_click_back
    then_i_see_the(:teacher_application_page)

    # teacher_application_page -> teacher_check_qualifications_page -> teacher_edit_qualification_page
    #  <- teacher_check_qualifications_page

    when_i_click_qualifications
    then_i_see_the(:teacher_check_qualifications_page)

    when_i_click_change_qualification_title
    then_i_see_the(
      :teacher_edit_qualification_page,
      qualification_id: qualification.id,
    )

    when_i_click_back
    then_i_see_the(:teacher_check_qualifications_page)

    # teacher_check_qualifications_page -> teacher_edit_qualification_page -> teacher_check_qualifications_page

    when_i_click_change_qualification_title
    then_i_see_the(
      :teacher_edit_qualification_page,
      qualification_id: qualification.id,
    )

    when_i_click_continue
    then_i_see_the(:teacher_check_qualifications_page)

    # teacher_check_qualifications_page -> document_form_page
    #  <- teacher_check_qualifications_page

    when_i_click_change_certificate_document_title
    then_i_see_the(:teacher_check_document_page)

    when_i_click_back
    then_i_see_the(:teacher_check_qualifications_page)

    # teacher_check_qualifications_page -> document_form_page -> teacher_check_qualifications_page

    when_i_click_change_certificate_document_title
    then_i_see_the(:teacher_check_document_page)

    when_i_dont_upload_another_document
    then_i_see_the(:teacher_check_qualifications_page)

    # teacher_check_qualifications_page -> document_form_page -> upload_document_page
    #  <- document_form_page <- teacher_check_qualifications_page

    when_i_click_change_certificate_document_title
    then_i_see_the(:teacher_check_document_page)

    when_i_do_upload_another_document
    then_i_see_the(:teacher_upload_document_page)

    when_i_click_back
    then_i_see_the(:teacher_check_document_page)

    when_i_click_back
    then_i_see_the(:teacher_check_qualifications_page)

    # teacher_check_qualifications_page -> document_form_page -> upload_document_page -> document_form_page
    #  <- teacher_check_qualifications_page

    when_i_click_change_certificate_document_title
    then_i_see_the(:teacher_check_document_page)

    when_i_do_upload_another_document
    then_i_see_the(:teacher_upload_document_page)

    when_i_upload_a_document
    then_i_see_the(:teacher_check_document_page)

    when_i_click_back
    then_i_see_the(:teacher_check_qualifications_page)

    # teacher_check_qualifications_page -> document_form_page -> upload_document_page -> document_form_page
    #  -> teacher_check_qualifications_page

    when_i_click_change_certificate_document_title
    then_i_see_the(:teacher_check_document_page)

    when_i_do_upload_another_document
    then_i_see_the(:teacher_upload_document_page)

    when_i_upload_a_document
    then_i_see_the(:teacher_check_document_page)

    when_i_dont_upload_another_document
    then_i_see_the(:teacher_check_qualifications_page)

    # teacher_check_qualifications_page -> teacher_add_another_qualification_page
    #  <- teacher_check_qualifications_page

    teacher_check_qualifications_page.continue_button.click
    then_i_see_the(:teacher_add_another_qualification_page)

    when_i_click_back
    then_i_see_the(:teacher_check_qualifications_page)

    # teacher_check_qualifications_page -> teacher_add_another_qualification_page -> teacher_new_qualification_page
    #  <- teacher_check_qualifications_page

    teacher_check_qualifications_page.continue_button.click
    then_i_see_the(:teacher_add_another_qualification_page)

    when_i_add_another_qualification
    then_i_see_the(:teacher_new_qualification_page)

    when_i_click_back
    then_i_see_the(:teacher_check_qualifications_page)
  end

  private

  def given_an_application_form_exists
    application_form
  end

  def when_i_click_back
    click_link "Back"
  end

  def when_i_click_qualifications
    teacher_application_page.qualifications_task_item.click
  end

  def and_i_fill_in_qualification
    teacher_new_qualification_page.form.title_field.fill_in with: "Title"
    teacher_new_qualification_page.form.institution_name_field.fill_in with:
      "Institution Name"
    teacher_new_qualification_page.form.institution_country_field.fill_in with:
      "France"
    teacher_new_qualification_page.form.start_date_month_field.fill_in with: "1"
    teacher_new_qualification_page.form.start_date_year_field.fill_in with:
      "2000"
    teacher_new_qualification_page.form.complete_date_month_field.fill_in with:
      "1"
    teacher_new_qualification_page.form.complete_date_year_field.fill_in with:
      "2003"
    teacher_new_qualification_page.form.certificate_date_month_field.fill_in with:
      "1"
    teacher_new_qualification_page.form.certificate_date_year_field.fill_in with:
      "2004"
    teacher_new_qualification_page.form.teaching_confirmation_checkbox.check
    teacher_new_qualification_page.form.continue_button.click
  end

  def when_i_upload_a_document
    teacher_upload_document_page.form.original_attachment.attach_file Rails.root.join(
      file_fixture("upload.pdf"),
    )
    teacher_upload_document_page.form.written_in_english_items.first.choose
    teacher_upload_document_page.form.continue_button.click
  end

  def when_i_dont_upload_another_document
    teacher_check_document_page.form.false_radio_item.choose
    teacher_check_document_page.form.continue_button.click
  end

  def when_i_do_upload_another_document
    teacher_check_document_page.form.true_radio_item.choose
    teacher_check_document_page.form.continue_button.click
  end

  def when_i_choose_part_of_degree
    teacher_teaching_qualification_part_of_degree_page.submit_yes
  end

  def when_i_click_change_qualification_title
    teacher_check_qualifications_page
      .summary_cards
      .first
      .find_row(key: "Teaching qualification title")
      .actions
      .link
      .click
  end

  def when_i_click_change_certificate_document_title
    teacher_check_qualifications_page
      .summary_cards
      .first
      .find_row(key: "Certificate document")
      .actions
      .link
      .click
  end

  def when_i_add_another_qualification
    teacher_add_another_qualification_page.submit_yes
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        teacher:,
        region: create(:region, :in_country, country_code: "FR"),
      )
  end

  def qualification
    @qualification ||= application_form.qualifications.first
  end
end
