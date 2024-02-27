# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher work history", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_a_user(teacher)
    given_an_application_form_exists
    given_malware_scanning_is_enabled
  end

  it "records work history" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_work_history_task

    when_i_click_the_work_history_task
    then_i_see_the(:teacher_new_work_history_page)

    when_i_fill_in_the_school_information
    then_i_see_the(:teacher_edit_work_history_contact_page)

    when_i_fill_in_the_contact_information
    then_i_see_the(:teacher_check_work_history_page)
    and_i_see_the_work_history_information

    when_i_click_continue
    then_i_see_the(:teacher_add_another_work_history_page)
    and_i_see_the_heading_with_the_number_of_months

    when_i_dont_add_another_work_history
    then_i_see_the(:teacher_application_page)
  end

  it "records work history with reduced evidence" do
    given_the_application_accepts_reduced_evidence

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_work_history_task

    when_i_click_the_work_history_task
    then_i_see_the(:teacher_new_work_history_page)

    when_i_fill_in_the_school_information
    then_i_see_the(:teacher_check_work_history_page)
    and_i_see_the_reduced_evidence_work_history_information

    when_i_click_continue
    then_i_see_the(:teacher_add_another_work_history_page)
    and_i_see_the_heading_with_the_number_of_months

    when_i_dont_add_another_work_history
    then_i_see_the(:teacher_application_page)
  end

  it "deletes work history" do
    given_some_work_history_exists

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_work_history_task

    when_i_click_the_work_history_task
    then_i_see_the(:teacher_check_work_histories_page)
    and_i_see_three_work_histories

    when_i_click_delete_work_history
    then_i_see_the(:teacher_delete_work_history_page)

    when_i_delete_work_history
    then_i_see_the(:teacher_check_work_histories_page)
    and_i_see_two_work_histories
  end

  private

  def given_an_application_form_exists
    application_form
  end

  def given_the_application_accepts_reduced_evidence
    application_form.update!(reduced_evidence_accepted: true)
  end

  def given_some_work_history_exists
    create_list(:work_history, 3, :completed, application_form:)
    ApplicationFormSectionStatusUpdater.call(application_form:)
  end

  def and_i_see_the_work_history_task
    expect(teacher_application_page.work_history_task_item).to_not be_nil
  end

  def when_i_click_the_work_history_task
    teacher_application_page.work_history_task_item.click
  end

  def when_i_fill_in_the_school_information
    teacher_new_work_history_page.form.meets_all_requirements_checkbox.click
    teacher_new_work_history_page.form.school_name_input.fill_in with: "School"
    teacher_new_work_history_page.form.city_input.fill_in with: "City"
    teacher_new_work_history_page.form.country_input.fill_in with: "France"
    teacher_new_work_history_page.form.job_input.fill_in with: "Job"
    teacher_new_work_history_page.form.hours_per_week_input.fill_in with: "30"
    teacher_new_work_history_page.form.start_date_month_input.fill_in with: "1"
    teacher_new_work_history_page.form.start_date_year_input.fill_in with:
      "2020"
    teacher_new_work_history_page.form.still_employed_radio_items.second.choose
    teacher_new_work_history_page.form.end_date_month_input.fill_in with: "12"
    teacher_new_work_history_page.form.end_date_year_input.fill_in with: "2021"
    teacher_new_work_history_page.form.continue_button.click
  end

  def when_i_fill_in_the_contact_information
    teacher_edit_work_history_contact_page.form.name_input.fill_in with: "Name"
    teacher_edit_work_history_contact_page.form.job_input.fill_in with: "Job"
    teacher_edit_work_history_contact_page.form.email_input.fill_in with:
      "contact@example.com"
    teacher_edit_work_history_contact_page.form.continue_button.click
  end

  def and_i_see_the_work_history_information
    summary_list_rows = teacher_check_work_history_page.summary_list.rows

    expect(summary_list_rows.count).to eq(10)

    expect(summary_list_rows[0].key.text).to eq("School name")
    expect(summary_list_rows[0].value.text).to eq("School")

    expect(summary_list_rows[1].key.text).to eq("City of institution")
    expect(summary_list_rows[1].value.text).to eq("City")

    expect(summary_list_rows[2].key.text).to eq("Country of institution")
    expect(summary_list_rows[2].value.text).to eq("France")

    expect(summary_list_rows[3].key.text).to eq("Your job role")
    expect(summary_list_rows[3].value.text).to eq("Job")

    expect(summary_list_rows[4].key.text).to eq("Hours per week")
    expect(summary_list_rows[4].value.text).to eq("30")

    expect(summary_list_rows[5].key.text).to eq("Role start date")
    expect(summary_list_rows[5].value.text).to eq("January 2020")

    expect(summary_list_rows[6].key.text).to eq("Role end date")
    expect(summary_list_rows[6].value.text).to eq("December 2021")

    expect(summary_list_rows[7].key.text).to eq("Reference contact’s full name")
    expect(summary_list_rows[7].value.text).to eq("Name")

    expect(summary_list_rows[8].key.text).to eq("Reference contact’s job title")
    expect(summary_list_rows[8].value.text).to eq("Job")

    expect(summary_list_rows[9].key.text).to eq(
      "Reference contact’s email address",
    )
    expect(summary_list_rows[9].value.text).to eq("contact@example.com")
  end

  def and_i_see_the_reduced_evidence_work_history_information
    summary_list_rows = teacher_check_work_history_page.summary_list.rows

    expect(summary_list_rows.count).to eq(7)

    expect(summary_list_rows[0].key.text).to eq("School name")
    expect(summary_list_rows[0].value.text).to eq("School")

    expect(summary_list_rows[1].key.text).to eq("City of institution")
    expect(summary_list_rows[1].value.text).to eq("City")

    expect(summary_list_rows[2].key.text).to eq("Country of institution")
    expect(summary_list_rows[2].value.text).to eq("France")

    expect(summary_list_rows[3].key.text).to eq("Your job role")
    expect(summary_list_rows[3].value.text).to eq("Job")

    expect(summary_list_rows[4].key.text).to eq("Hours per week")
    expect(summary_list_rows[4].value.text).to eq("30")

    expect(summary_list_rows[5].key.text).to eq("Role start date")
    expect(summary_list_rows[5].value.text).to eq("January 2020")

    expect(summary_list_rows[6].key.text).to eq("Role end date")
    expect(summary_list_rows[6].value.text).to eq("December 2021")
  end

  def when_i_click_continue
    teacher_check_work_history_page.continue_button.click
  end

  def and_i_see_the_heading_with_the_number_of_months
    expect(teacher_add_another_work_history_page.heading.text).to eq(
      "You’ve added 24 months of work experience",
    )
  end

  def when_i_dont_add_another_work_history
    teacher_add_another_work_history_page.submit_no
  end

  def and_i_see_three_work_histories
    expect(teacher_check_work_histories_page.summary_cards.count).to eq(3)
  end

  def when_i_click_delete_work_history
    teacher_check_work_histories_page
      .summary_cards
      .first
      .actions
      .items
      .first
      .link
      .click
  end

  def when_i_delete_work_history
    teacher_delete_work_history_page.form.true_radio_item.choose
    teacher_delete_work_history_page.form.continue_button.click
  end

  def and_i_see_two_work_histories
    expect(teacher_check_work_histories_page.summary_cards.count).to eq(2)
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def application_form
    @application_form ||=
      create(:application_form, teacher:, needs_work_history: true)
  end
end
