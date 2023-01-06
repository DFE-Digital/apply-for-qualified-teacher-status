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

    reference_request.update!(
      hours_response: true,
      children_response: true,
      lessons_response: true,
      reports_response: true,
    )

    when_i_click_start_now
    then_i_see_the(:teacher_edit_reference_request_dates_page, slug:)

    when_i_choose_yes_for_dates
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

  def and_i_see_the_answers
    summary_list = teacher_check_reference_request_answers_page.summary_list

    expect(summary_list).to be_visible

    expect(summary_list.rows.first.key.text).to eq(
      "Did the applicant work at the school for the dates they provided?",
    )
    expect(summary_list.rows.first.value.text).to eq("Yes")
  end

  def when_i_submit_the_response
    teacher_check_reference_request_answers_page.submit_button.click
  end

  def and_i_see_the_confirmation_panel
    expect(teacher_reference_received_page.confirmation_panel).to be_visible
  end

  def reference_request
    @reference_request ||= create(:reference_request, :requested)
  end

  delegate :slug, to: :reference_request
end
