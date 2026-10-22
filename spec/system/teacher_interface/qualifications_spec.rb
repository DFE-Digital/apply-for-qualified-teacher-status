# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher qualifications", type: :system do
  before { given_i_am_authorized_as_a_user(teacher) }

  it "records qualifications" do
    given_an_application_form_exists
    given_malware_scanning_is_enabled

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_qualifications_task

    when_i_click_the_qualifications_task
    then_i_see_the(:teacher_new_qualification_page)
    and_i_dont_see_the_age_subject_restrictions

    when_i_fill_in_the_qualification_information
    then_i_see_the(:teacher_upload_document_page)

    when_i_upload_a_file
    then_i_see_the(:teacher_check_document_page)

    when_i_dont_need_to_upload_another_file
    then_i_see_the(:teacher_upload_document_page)

    when_i_upload_a_file
    then_i_see_the(:teacher_check_document_page)

    when_i_dont_need_to_upload_another_file
    then_i_see_the(:teacher_teaching_qualification_part_of_degree_page)

    when_the_qualification_is_part_of_the_degree
    then_i_see_the(:teacher_check_qualification_page)
    and_i_see_the_qualification_information

    when_i_click_continue
    then_i_see_the(:teacher_add_another_qualification_page)

    when_i_dont_add_another_qualification
    then_i_see_the(:teacher_application_page)
  end

  it "deletes qualifications" do
    given_an_application_form_exists
    given_malware_scanning_is_disabled
    given_some_qualifications_exist

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_qualifications_task

    when_i_click_the_qualifications_task
    then_i_see_the(:teacher_check_qualifications_page)
    and_i_see_three_qualifications

    when_i_click_delete_qualification
    then_i_see_the(:teacher_delete_qualification_page)

    when_i_delete_qualification
    then_i_see_the(:teacher_check_qualifications_page)
    and_i_see_two_qualifications
  end

  it "subject restricted countries" do
    given_the_country_is_subject_limited
    given_an_application_form_exists

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_qualifications_task

    when_i_click_the_qualifications_task
    then_i_see_the(:teacher_new_qualification_page)
    and_i_see_the_age_subject_restrictions
  end

  it "partially saved additional qualification" do
    given_a_completed_teaching_qualification_exists

    when_i_visit_the(:teacher_application_page)
    when_i_click_the_qualifications_task
    then_i_see_the(:teacher_check_qualifications_page)

    when_i_continue_from_the_qualifications_collection
    then_i_see_the(:teacher_add_another_qualification_page)
    when_i_add_another_qualification
    then_i_see_the(:teacher_new_qualification_page)

    when_i_save_partial_qualification_details
    then_i_see_the(:teacher_application_page)
    and_the_qualifications_task_is("In progress")

    when_i_click_the_qualifications_task
    then_i_see_the(:teacher_check_qualifications_page)
    and_i_see_the_partial_additional_qualification

    when_i_continue_from_the_qualifications_collection
    then_i_see_the_edit_for_saved_incomplete_additional_qualification
  end

  it "partially saved teaching qualification" do
    given_an_application_form_exists

    when_i_visit_the(:teacher_application_page)
    when_i_click_the_qualifications_task
    then_i_see_the(:teacher_new_qualification_page)

    when_i_save_partial_qualification_details
    then_i_see_the(:teacher_application_page)
    and_the_qualifications_task_is("In progress")

    when_i_click_the_qualifications_task
    then_i_see_the(:teacher_edit_qualification_page)
    and_i_see_the_saved_teaching_qualification
  end

  it "ability to add another for already completed qualifications" do
    given_some_qualifications_exist

    when_i_visit_the(:teacher_application_page)
    and_the_qualifications_task_is("Completed")
    when_i_click_the_qualifications_task
    then_i_see_the(:teacher_check_qualifications_page)

    and_i_see_the_completed_qualification

    when_i_continue_from_the_qualifications_collection
    then_i_see_the(:teacher_add_another_qualification_page)
  end

  it "editing an incomplete qualification" do
    given_a_completed_teaching_qualification_exists
    given_an_incomplete_additional_qualification_exists

    when_i_visit_the(:teacher_application_page)
    when_i_click_the_qualifications_task
    then_i_see_the(:teacher_check_qualifications_page)

    when_i_change_the_additional_qualification(
      field: "Additional qualification title",
    )
    then_i_see_the(:teacher_edit_qualification_page)

    when_i_save_the_amended_qualification
    then_i_see_the(:teacher_application_page)
    and_the_qualifications_task_is("In progress")
  end

  it "saves an unfinished qualification document and returns to the task list" do
    given_a_completed_teaching_qualification_exists
    given_an_incomplete_additional_qualification_exists

    when_i_visit_the(:teacher_application_page)
    when_i_click_the_qualifications_task
    then_i_see_the(:teacher_check_qualifications_page)

    when_i_change_the_additional_qualification(field: "Certificate document")
    then_i_see_the(:teacher_upload_document_page)

    when_i_save_the_unfinished_document
    then_i_see_the(:teacher_application_page)
    and_the_qualifications_task_is("In progress")
  end

  private

  def when_i_continue_from_the_qualifications_collection
    teacher_check_qualifications_page.continue_button.click
  end

  def when_i_add_another_qualification
    teacher_add_another_qualification_page.submit_yes
  end

  def when_i_change_the_additional_qualification(field:)
    teacher_check_qualifications_page
      .summary_cards
      .second
      .find_row(key: field)
      .actions
      .link
      .click
  end

  def when_i_save_the_amended_qualification
    teacher_edit_qualification_page.form.title_field.fill_in with:
      "Example amended diploma"
    teacher_edit_qualification_page.form.save_and_come_back_later_button.click
  end

  def when_i_save_the_unfinished_document
    teacher_upload_document_page.form.save_and_come_back_later_button.click
  end

  def then_i_see_the_edit_for_saved_incomplete_additional_qualification
    then_i_see_the(
      :teacher_edit_qualification_page,
      qualification_id: application_form.qualifications.order_by_user.last.id,
    )
    and_i_see_the_saved_institution_name
  end

  def and_i_see_the_saved_teaching_qualification
    expect(teacher_edit_qualification_page.heading.text).to eq(
      "Teaching qualification",
    )
    expect(teacher_edit_qualification_page.form.title_field.value).to eq(
      "Example teaching diploma",
    )
    and_i_see_the_saved_institution_name
  end

  def and_i_see_the_saved_institution_name
    expect(
      teacher_edit_qualification_page.form.institution_name_field.value,
    ).to eq("Example University")
  end

  def and_i_see_the_completed_qualification
    first_qualification = application_form.qualifications.order_by_user.first
    first_card = teacher_check_qualifications_page.summary_cards.first
    expect(first_card.heading.text).to eq(
      "#{first_qualification.title} (#{first_qualification.institution_name})",
    )
    expect(
      first_card.find_row(key: "Certificate document").value.text,
    ).to include(
      first_qualification.certificate_document.uploads.first.filename,
    )
  end

  def given_a_completed_teaching_qualification_exists
    create(:qualification, :completed, application_form:)
    application_form.update!(teaching_qualification_part_of_degree: true)
    ApplicationFormSectionStatusUpdater.call(application_form:)
  end

  def given_an_incomplete_additional_qualification_exists
    create(:qualification, application_form:)
    ApplicationFormSectionStatusUpdater.call(application_form:)
  end

  def when_i_save_partial_qualification_details
    teacher_new_qualification_page.form.title_field.fill_in with:
      "Example teaching diploma"
    teacher_new_qualification_page.form.institution_name_field.fill_in with:
      "Example University"
    teacher_new_qualification_page.form.save_and_come_back_later_button.click
  end

  def and_the_qualifications_task_is(status)
    expect(
      teacher_application_page.qualifications_task_item.status_tag.text,
    ).to eq(status)
  end

  def and_i_see_the_partial_additional_qualification
    card = teacher_check_qualifications_page.summary_cards.second

    expect(card.heading.text).to eq(
      "Example teaching diploma (Example University)",
    )
    expect(
      card.find_row(key: "Additional qualification title").value.text,
    ).to eq("Example teaching diploma")
    expect(card.find_row(key: "Name of institution").value.text).to eq(
      "Example University",
    )
    expect(
      card.find_row(key: "When did you start this qualification?").value.text,
    ).to eq("Not provided")
    expect(card.find_row(key: "Certificate document").value.text).to eq(
      "Not provided",
    )
  end

  def given_an_application_form_exists
    application_form
  end

  def given_some_qualifications_exist
    create_list(:qualification, 3, :completed, application_form:)
    application_form.update!(teaching_qualification_part_of_degree: true)
    ApplicationFormSectionStatusUpdater.call(application_form:)
  end

  def given_the_country_is_subject_limited
    @country = create(:country, :subject_limited)
  end

  def and_i_see_the_qualifications_task
    expect(teacher_application_page.qualifications_task_item).not_to be_nil
  end

  def when_i_click_the_qualifications_task
    teacher_application_page.qualifications_task_item.click
  end

  def and_i_see_the_age_subject_restrictions
    expect(teacher_new_qualification_page).to have_content(
      "Additional age and subject requirements",
    )
  end

  def and_i_dont_see_the_age_subject_restrictions
    expect(teacher_new_qualification_page).not_to have_content(
      "Additional age and subject requirements",
    )
  end

  def when_i_fill_in_the_qualification_information
    teacher_new_qualification_page.form.title_field.fill_in with: "BSc Teaching"
    teacher_new_qualification_page.form.institution_name_field.fill_in with:
      "University of Paris"
    teacher_new_qualification_page.form.institution_country_field.fill_in with:
      "France"
    teacher_new_qualification_page.form.start_date_month_field.fill_in with: "1"
    teacher_new_qualification_page.form.start_date_year_field.fill_in with:
      "1999"
    teacher_new_qualification_page.form.complete_date_month_field.fill_in with:
      "1"
    teacher_new_qualification_page.form.complete_date_year_field.fill_in with:
      "2003"
    teacher_new_qualification_page.form.certificate_date_month_field.fill_in with:
      "12"
    teacher_new_qualification_page.form.certificate_date_year_field.fill_in with:
      "2003"
    teacher_new_qualification_page.form.teaching_confirmation_checkbox.check
    teacher_new_qualification_page.form.continue_button.click
  end

  def when_i_upload_a_file
    teacher_upload_document_page.form.original_attachment.attach_file Rails.root.join(
      file_fixture("upload.pdf"),
    )
    teacher_upload_document_page.form.written_in_english_items.first.choose
    teacher_upload_document_page.form.continue_button.click
  end

  def when_i_dont_need_to_upload_another_file
    teacher_check_document_page.form.false_radio_item.input.click
    teacher_check_document_page.form.continue_button.click
  end

  def when_the_qualification_is_part_of_the_degree
    teacher_teaching_qualification_part_of_degree_page.submit_yes
  end

  def and_i_see_the_qualification_information
    summary_list_rows = teacher_check_qualification_page.summary_list.rows

    expect(summary_list_rows.count).to eq(9)

    expect(summary_list_rows[0].key.text).to eq("Teaching qualification title")
    expect(summary_list_rows[0].value.text).to eq("BSc Teaching")

    expect(summary_list_rows[1].key.text).to eq("Name of institution")
    expect(summary_list_rows[1].value.text).to eq("University of Paris")

    expect(summary_list_rows[2].key.text).to eq("Country of institution")
    expect(summary_list_rows[2].value.text).to eq("France")

    expect(summary_list_rows[3].key.text).to eq(
      "When did you start this qualification?",
    )
    expect(summary_list_rows[3].value.text).to eq("January 1999")

    expect(summary_list_rows[4].key.text).to eq(
      "When did you complete this qualification?",
    )
    expect(summary_list_rows[4].value.text).to eq("January 2003")

    expect(summary_list_rows[5].key.text).to eq(
      "When were you awarded this qualification?",
    )
    expect(summary_list_rows[5].value.text).to eq("December 2003")

    expect(summary_list_rows[6].key.text).to eq("Certificate document")
    expect(summary_list_rows[6].value.text).to eq(
      "upload.pdf (opens in new tab)",
    )

    expect(summary_list_rows[7].key.text).to eq("Transcript document")
    expect(summary_list_rows[7].value.text).to eq(
      "upload.pdf (opens in new tab)",
    )

    expect(summary_list_rows[8].key.text).to eq(
      "Part of your bachelor’s degree?",
    )
    expect(summary_list_rows[8].value.text).to eq("Yes")
  end

  def when_i_click_continue
    teacher_check_work_history_page.continue_button.click
  end

  def when_i_dont_add_another_qualification
    teacher_add_another_qualification_page.submit_no
  end

  def and_i_see_three_qualifications
    expect(teacher_check_qualifications_page.summary_cards.count).to eq(3)
  end

  def when_i_click_delete_qualification
    teacher_check_qualifications_page.summary_cards.second.actions.link.click
  end

  def when_i_delete_qualification
    teacher_delete_qualification_page.form.true_radio_item.choose
    teacher_delete_qualification_page.form.continue_button.click
  end

  def and_i_see_two_qualifications
    expect(teacher_check_work_histories_page.summary_cards.count).to eq(2)
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def country
    @country ||= create(:country, code: "FR")
  end

  def application_form
    @application_form ||=
      create(:application_form, region: create(:region, country:), teacher:)
  end
end
