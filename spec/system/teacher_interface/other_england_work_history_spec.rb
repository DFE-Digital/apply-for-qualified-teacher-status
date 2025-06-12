# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher work history in England", type: :system do
  before do
    given_i_am_authorized_as_a_user(teacher)
    given_an_application_form_exists
    given_some_work_history_exists
    given_malware_scanning_is_enabled
  end

  it "does not have any other work history in England" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_other_england_work_history_task

    when_i_click_the_other_england_work_history_task
    then_i_see_the(:teacher_meets_criteria_other_england_work_history_page)

    when_i_choose_no_to_having_other_work_experience_in_england
    then_i_see_the(:teacher_application_page)
    and_i_see_other_work_experience_in_england_task_as_completed
  end

  it "adding other work history in England" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_other_england_work_history_task

    when_i_click_the_other_england_work_history_task
    then_i_see_the(:teacher_meets_criteria_other_england_work_history_page)

    when_i_choose_yes_to_having_other_work_experience_in_england
    then_i_see_the(:teacher_new_other_england_work_history_page)

    when_i_fill_in_the_school_information(name: "Other School 1")
    then_i_see_the(:teacher_edit_other_england_work_history_contact_page)

    when_i_fill_in_the_contact_information
    then_i_see_the(:teacher_check_other_england_work_history_page)
    and_i_see_the_other_england_work_history_information(name: "Other School 1")

    when_i_click_continue
    then_i_see_the(:teacher_add_another_other_england_work_history_page)

    when_i_do_add_another_other_england_work_history
    then_i_see_the(:teacher_new_other_england_work_history_page)

    when_i_fill_in_the_school_information(name: "Other School 2")
    then_i_see_the(:teacher_edit_other_england_work_history_contact_page)

    when_i_fill_in_the_contact_information
    then_i_see_the(:teacher_check_other_england_work_history_page)
    and_i_see_the_other_england_work_history_information(name: "Other School 2")

    when_i_click_continue
    then_i_see_the(:teacher_add_another_other_england_work_history_page)

    when_i_dont_add_another_other_england_work_history
    then_i_see_the(:teacher_check_other_england_work_histories_page)

    when_i_click_continue
    then_i_see_the(:teacher_application_page)
    and_i_see_other_work_experience_in_england_task_as_completed
  end

  it "deletes work history" do
    given_some_other_england_work_history_exists

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_other_england_work_history_task

    when_i_click_the_other_england_work_history_task
    then_i_see_the(:teacher_check_other_england_work_histories_page)
    and_i_see_three_work_histories

    when_i_click_delete_work_history
    then_i_see_the(:teacher_delete_other_england_work_history_page)
    when_i_delete_work_history
    then_i_see_the(:teacher_check_other_england_work_histories_page)
    and_i_see_two_work_histories

    when_i_click_delete_work_history
    then_i_see_the(:teacher_delete_other_england_work_history_page)
    when_i_delete_work_history
    then_i_see_the(:teacher_check_other_england_work_histories_page)
    and_i_see_one_work_history

    when_i_click_delete_work_history
    then_i_see_the(:teacher_delete_other_england_work_history_page)
    when_i_delete_work_history
    then_i_see_the(:teacher_meets_criteria_other_england_work_history_page)
  end

  private

  def given_an_application_form_exists
    application_form
  end

  def given_some_work_history_exists
    create_list(:work_history, 3, :completed, application_form:)
    ApplicationFormSectionStatusUpdater.call(application_form:)
  end

  def given_some_other_england_work_history_exists
    create_list(
      :work_history,
      3,
      :other_england_role,
      :completed,
      application_form:,
      country_code: "GB-ENG",
    )
    application_form.update!(has_other_england_work_history: true)
    ApplicationFormSectionStatusUpdater.call(application_form:)
  end

  def and_i_see_the_other_england_work_history_task
    expect(
      teacher_application_page.other_england_work_history_task_item,
    ).not_to be_nil
  end

  def when_i_click_the_other_england_work_history_task
    teacher_application_page.other_england_work_history_task_item.click
  end

  def when_i_choose_no_to_having_other_work_experience_in_england
    teacher_meets_criteria_other_england_work_history_page.submit_no
  end

  def when_i_choose_yes_to_having_other_work_experience_in_england
    teacher_meets_criteria_other_england_work_history_page.submit_yes
  end

  def and_i_see_other_work_experience_in_england_task_as_completed
    expect(
      teacher_application_page.other_england_work_history_task_item,
    ).to have_content("Completed")
  end

  def when_i_fill_in_the_school_information(name:)
    teacher_new_other_england_work_history_page.form.school_name_input.fill_in with:
      name
    teacher_new_other_england_work_history_page.form.address_line1_input.fill_in with:
      "Building A"
    teacher_new_other_england_work_history_page.form.address_line2_input.fill_in with:
      "Street B"
    teacher_new_other_england_work_history_page.form.city_input.fill_in with:
      "City"
    teacher_new_other_england_work_history_page.form.country_input.fill_in with:
      "England"
    teacher_new_other_england_work_history_page.form.postcode_input.fill_in with:
      "12345"
    teacher_new_other_england_work_history_page.form.school_website_input.fill_in with:
      "www.schoolwebsite.com"
    teacher_new_other_england_work_history_page.form.job_input.fill_in with:
      "Job"
    teacher_new_other_england_work_history_page.form.start_date_month_input.fill_in with:
      "1"
    teacher_new_other_england_work_history_page.form.start_date_year_input.fill_in with:
      "2020"
    teacher_new_other_england_work_history_page
      .form
      .still_employed_radio_items
      .second
      .choose
    teacher_new_other_england_work_history_page.form.end_date_month_input.fill_in with:
      "12"
    teacher_new_other_england_work_history_page.form.end_date_year_input.fill_in with:
      "2021"
    teacher_new_other_england_work_history_page.form.continue_button.click
  end

  def when_i_fill_in_the_contact_information
    teacher_edit_other_england_work_history_contact_page.form.name_input.fill_in with:
      "Name"
    teacher_edit_other_england_work_history_contact_page.form.job_input.fill_in with:
      "Job"
    teacher_edit_other_england_work_history_contact_page.form.email_input.fill_in with:
      "contact@example.com"
    teacher_edit_other_england_work_history_contact_page
      .form
      .continue_button
      .click
  end

  def and_i_see_the_other_england_work_history_information(name:)
    summary_list_rows = teacher_check_work_history_page.summary_list.rows

    expect(summary_list_rows.count).to eq(13)

    expect(summary_list_rows[0].key.text).to eq("Name of institution")
    expect(summary_list_rows[0].value.text).to eq(name)

    expect(summary_list_rows[1].key.text).to eq("Address line 1 of institution")
    expect(summary_list_rows[1].value.text).to eq("Building A")

    expect(summary_list_rows[2].key.text).to eq("Address line 2 of institution")
    expect(summary_list_rows[2].value.text).to eq("Street B")

    expect(summary_list_rows[3].key.text).to eq("Town or city of institution")
    expect(summary_list_rows[3].value.text).to eq("City")

    expect(summary_list_rows[4].key.text).to eq("Country of institution")
    expect(summary_list_rows[4].value.text).to eq("England")

    expect(summary_list_rows[5].key.text).to eq("Postcode of institution")
    expect(summary_list_rows[5].value.text).to eq("12345")

    expect(summary_list_rows[6].key.text).to eq("Institution webpage")
    expect(summary_list_rows[6].value.text).to eq("www.schoolwebsite.com")

    expect(summary_list_rows[7].key.text).to eq("Your job role")
    expect(summary_list_rows[7].value.text).to eq("Job")

    expect(summary_list_rows[8].key.text).to eq("Role start date")
    expect(summary_list_rows[8].value.text).to eq("January 2020")

    expect(summary_list_rows[9].key.text).to eq("Role end date")
    expect(summary_list_rows[9].value.text).to eq("December 2021")

    expect(summary_list_rows[10].key.text).to eq(
      "Reference contact’s full name",
    )
    expect(summary_list_rows[10].value.text).to eq("Name")

    expect(summary_list_rows[11].key.text).to eq(
      "Reference contact’s job title",
    )
    expect(summary_list_rows[11].value.text).to eq("Job")

    expect(summary_list_rows[12].key.text).to eq(
      "Reference contact’s email address",
    )
    expect(summary_list_rows[12].value.text).to eq("contact@example.com")
  end

  def when_i_click_continue
    teacher_check_work_history_page.continue_button.click
  end

  def when_i_do_add_another_other_england_work_history
    teacher_add_another_other_england_work_history_page.submit_yes
  end

  def when_i_dont_add_another_other_england_work_history
    teacher_add_another_other_england_work_history_page.submit_no
  end

  def and_i_see_three_work_histories
    expect(
      teacher_check_other_england_work_histories_page.summary_cards.count,
    ).to eq(3)
  end

  def and_i_see_two_work_histories
    expect(
      teacher_check_other_england_work_histories_page.summary_cards.count,
    ).to eq(2)
  end

  def and_i_see_one_work_history
    expect(
      teacher_check_other_england_work_histories_page.summary_cards.count,
    ).to eq(1)
  end

  def when_i_click_delete_work_history
    teacher_check_other_england_work_histories_page
      .summary_cards
      .first
      .actions
      .items
      .first
      .link
      .click
  end

  def when_i_delete_work_history
    teacher_delete_other_england_work_history_page.form.true_radio_item.choose
    teacher_delete_other_england_work_history_page.form.continue_button.click
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        teacher:,
        needs_work_history: true,
        includes_prioritisation_features: true,
      )
  end
end
