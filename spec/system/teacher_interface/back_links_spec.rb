# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher back links", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_a_user(teacher)
    given_an_application_form_exists
  end

  it "back links follow user" do
    # teacher_application_page -> new_qualification_page
    #  <- teacher_application_page

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)

    when_i_click_qualifications
    then_i_see_the(:new_qualification_page)

    when_i_click_back
    then_i_see_the(:teacher_application_page)

    # teacher_application_page -> new_qualification_page -> upload_document_page
    #  <- edit_qualification_page <- teacher_application_page

    when_i_click_qualifications
    and_i_fill_in_qualification
    then_i_see_the(:upload_document_page)

    when_i_click_back
    then_i_see_the(:edit_qualification_page, qualification_id: qualification.id)

    when_i_click_back
    then_i_see_the(:teacher_application_page)

    # teacher_application_page -> edit_qualification_page -> upload_document_page -> document_form_page
    #  <- edit_qualification_page

    when_i_click_qualifications
    and_i_click_continue
    then_i_see_the(:upload_document_page)

    when_i_upload_a_document
    then_i_see_the(:document_form_page)

    when_i_click_back
    then_i_see_the(:edit_qualification_page, qualification_id: qualification.id)

    # edit_qualification_page -> document_form_page -> upload_document_page -> document_form_page
    #  -> part_of_university_degree_page
    #  <- document_form_page <- document_form_page <- edit_qualification_page

    when_i_click_continue
    then_i_see_the(:document_form_page)

    when_i_dont_upload_another_document
    then_i_see_the(:upload_document_page)

    when_i_upload_a_document
    then_i_see_the(:document_form_page)

    when_i_dont_upload_another_document
    then_i_see_the(
      :part_of_university_degree_page,
      qualification_id: qualification.id,
    )

    when_i_click_back
    then_i_see_the(:document_form_page)

    when_i_click_back
    then_i_see_the(:document_form_page)

    when_i_click_back
    then_i_see_the(:edit_qualification_page, qualification_id: qualification.id)

    # edit_qualification_page -> document_form_page -> document_form_page -> part_of_university_degree_page
    #  -> teacher_check_qualification_page
    #  <- teacher_application_page

    when_i_click_continue
    then_i_see_the(:document_form_page)

    when_i_dont_upload_another_document
    then_i_see_the(:document_form_page)

    when_i_dont_upload_another_document
    then_i_see_the(
      :part_of_university_degree_page,
      qualification_id: qualification.id,
    )

    when_i_choose_part_of_university_degree
    then_i_see_the(:teacher_check_qualification_page)

    when_i_click_back
    then_i_see_the(:teacher_application_page)

    # teacher_application_page -> teacher_check_qualifications_page -> edit_qualification_page
    #  <- teacher_check_qualifications_page

    when_i_click_qualifications
    then_i_see_the(:teacher_check_qualifications_page)

    when_i_click_change_qualification_title
    then_i_see_the(:edit_qualification_page, qualification_id: qualification.id)

    when_i_click_back
    then_i_see_the(:teacher_check_qualifications_page)

    # teacher_check_qualifications_page -> edit_qualification_page -> teacher_check_qualifications_page

    when_i_click_change_qualification_title
    then_i_see_the(:edit_qualification_page, qualification_id: qualification.id)

    when_i_click_continue
    then_i_see_the(:teacher_check_qualifications_page)

    # teacher_check_qualifications_page -> document_form_page
    #  <- teacher_check_qualifications_page

    when_i_click_change_certificate_document_title
    then_i_see_the(:document_form_page)

    when_i_click_back
    then_i_see_the(:teacher_check_qualifications_page)

    # teacher_check_qualifications_page -> document_form_page -> teacher_check_qualifications_page

    when_i_click_change_certificate_document_title
    then_i_see_the(:document_form_page)

    when_i_dont_upload_another_document
    then_i_see_the(:teacher_check_qualifications_page)

    # teacher_check_qualifications_page -> document_form_page -> upload_document_page
    #  <- document_form_page <- teacher_check_qualifications_page

    when_i_click_change_certificate_document_title
    then_i_see_the(:document_form_page)

    when_i_do_upload_another_document
    then_i_see_the(:upload_document_page)

    when_i_click_back
    then_i_see_the(:document_form_page)

    when_i_click_back
    then_i_see_the(:teacher_check_qualifications_page)

    # teacher_check_qualifications_page -> document_form_page -> upload_document_page -> document_form_page
    #  <- teacher_check_qualifications_page

    when_i_click_change_certificate_document_title
    then_i_see_the(:document_form_page)

    when_i_do_upload_another_document
    then_i_see_the(:upload_document_page)

    when_i_upload_a_document
    then_i_see_the(:document_form_page)

    when_i_click_back
    then_i_see_the(:teacher_check_qualifications_page)

    # teacher_check_qualifications_page -> document_form_page -> upload_document_page -> document_form_page
    #  -> teacher_check_qualifications_page

    when_i_click_change_certificate_document_title
    then_i_see_the(:document_form_page)

    when_i_do_upload_another_document
    then_i_see_the(:upload_document_page)

    when_i_upload_a_document
    then_i_see_the(:document_form_page)

    when_i_dont_upload_another_document
    then_i_see_the(:teacher_check_qualifications_page)

    # teacher_check_qualifications_page -> add_another_qualification_page
    #  <- teacher_check_qualifications_page

    teacher_check_qualifications_page.continue_button.click
    then_i_see_the(:add_another_qualification_page)

    when_i_click_back
    then_i_see_the(:teacher_check_qualifications_page)

    # teacher_check_qualifications_page -> add_another_qualification_page -> new_qualification_page
    #  <- teacher_check_qualifications_page

    teacher_check_qualifications_page.continue_button.click
    then_i_see_the(:add_another_qualification_page)

    when_i_add_another_qualification
    then_i_see_the(:new_qualification_page)

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
    new_qualification_page.form.title.fill_in with: "Title"
    new_qualification_page.form.institution_name.fill_in with:
      "Institution Name"
    new_qualification_page.form.institution_country.fill_in with: "France"
    new_qualification_page.form.start_date_month.fill_in with: "1"
    new_qualification_page.form.start_date_year.fill_in with: "2000"
    new_qualification_page.form.complete_date_month.fill_in with: "1"
    new_qualification_page.form.complete_date_year.fill_in with: "2003"
    new_qualification_page.form.certificate_date_month.fill_in with: "1"
    new_qualification_page.form.certificate_date_year.fill_in with: "2004"
    new_qualification_page.form.continue_button.click
  end

  def when_i_upload_a_document
    upload_document_page.form.original_attachment.attach_file Rails.root.join(
      file_fixture("upload.pdf"),
    )
    upload_document_page.form.written_in_english_items.first.choose
    upload_document_page.form.continue_button.click
  end

  def when_i_dont_upload_another_document
    document_form_page.form.no_radio_item.choose
    document_form_page.form.continue_button.click
  end

  def when_i_do_upload_another_document
    document_form_page.form.yes_radio_item.choose
    document_form_page.form.continue_button.click
  end

  def when_i_choose_part_of_university_degree
    part_of_university_degree_page.form.yes_radio_item.choose
    part_of_university_degree_page.form.continue_button.click
  end

  def when_i_click_change_qualification_title
    teacher_check_qualifications_page
      .summary_lists
      .first
      .find_row(key: "Qualification title")
      .actions
      .link
      .click
  end

  def when_i_click_change_certificate_document_title
    teacher_check_qualifications_page
      .summary_lists
      .first
      .find_row(key: "Certificate document")
      .actions
      .link
      .click
  end

  def when_i_add_another_qualification
    add_another_qualification_page.form.yes_radio_item.choose
    add_another_qualification_page.form.continue_button.click
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
