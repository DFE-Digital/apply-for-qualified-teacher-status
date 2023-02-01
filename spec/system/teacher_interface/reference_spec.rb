# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher reference", type: :system do
  before do
    given_the_service_is_open
    given_there_is_a_reference_request
  end

  it "allows filling in the reference" do
    when_i_visit_the(:teacher_reference_requested_page, slug:)
    then_i_see_the(:teacher_reference_requested_page, slug:)
    and_i_see_the_work_history_details

    when_i_click_start_now
    then_i_see_the(:teacher_edit_reference_request_dates_page, slug:)

    when_i_choose_yes_for_dates
    then_i_see_the(:teacher_edit_reference_request_hours_page, slug:)

    when_i_choose_yes_for_hours
    then_i_see_the(:teacher_edit_reference_request_children_page, slug:)

    when_i_choose_yes_for_children
    then_i_see_the(:teacher_edit_reference_request_lessons_page, slug:)

    when_i_choose_yes_for_lessons
    then_i_see_the(:teacher_edit_reference_request_reports_page, slug:)

    when_i_choose_yes_for_reports
    then_i_see_the(
      :teacher_edit_reference_request_additional_information_page,
      slug:,
    )

    when_i_fill_in_additional_information
    then_i_see_the(:teacher_check_reference_request_answers_page, slug:)
    and_i_see_the_answers

    when_i_submit_the_response
    then_i_see_the(:teacher_reference_received_page, slug:)
    and_i_see_the_confirmation_panel
  end

  def given_there_is_a_reference_request
    reference_request
  end

  def and_i_see_the_work_history_details
    expect(teacher_reference_requested_page.work_history_details.text).to eq(
      "School from January 2020 to January 2023",
    )
  end

  def when_i_click_start_now
    teacher_reference_requested_page.start_button.click
  end

  def when_i_choose_yes_for_dates
    teacher_edit_reference_request_dates_page.submit_yes
  end

  def when_i_choose_yes_for_hours
    teacher_edit_reference_request_hours_page.submit_yes
  end

  def when_i_choose_yes_for_children
    teacher_edit_reference_request_children_page.submit_yes
  end

  def when_i_choose_yes_for_lessons
    teacher_edit_reference_request_lessons_page.submit_yes
  end

  def when_i_choose_yes_for_reports
    teacher_edit_reference_request_reports_page.submit_yes
  end

  def when_i_fill_in_additional_information
    teacher_edit_reference_request_additional_information_page.submit(
      additional_information: "Some information.",
    )
  end

  def and_i_see_the_answers
    summary_list = teacher_check_reference_request_answers_page.summary_list

    expect(summary_list).to be_visible

    expect(summary_list.rows[0].key.text).to eq(
      "Did the applicant work at the school for the dates they provided?",
    )
    expect(summary_list.rows[0].value.text).to eq("Yes")

    expect(summary_list.rows[1].key.text).to eq(
      "Did they work approximately 30 hours per week in this role?",
    )
    expect(summary_list.rows[1].value.text).to eq("Yes")

    expect(summary_list.rows[2].key.text).to eq(
      "Did the applicant work unsupervised with children aged somewhere between 5 and 16 years?",
    )
    expect(summary_list.rows[2].value.text).to eq("Yes")

    expect(summary_list.rows[3].key.text).to eq(
      "Was the applicant solely responsible for planning, preparing and delivering lessons" \
        " to at least 4 students at a time?",
    )
    expect(summary_list.rows[3].value.text).to eq("Yes")

    expect(summary_list.rows[4].key.text).to eq(
      "Was the applicant solely responsible for assessing and reporting on the progress of" \
        " the students?",
    )
    expect(summary_list.rows[4].value.text).to eq("Yes")

    expect(summary_list.rows[5].key.text).to eq(
      "Is there anything else you’d like to tell us about this applicant?",
    )
    expect(summary_list.rows[5].value.text).to eq("Some information.")
  end

  def when_i_submit_the_response
    teacher_check_reference_request_answers_page.submit_button.click
  end

  def and_i_see_the_confirmation_panel
    expect(teacher_reference_received_page.confirmation_panel).to be_visible
  end

  def reference_request
    @reference_request ||=
      create(
        :reference_request,
        :requested,
        work_history:
          create(:work_history, :completed, end_date: Date.new(2023, 1, 1)),
      )
  end

  delegate :slug, to: :reference_request
end
