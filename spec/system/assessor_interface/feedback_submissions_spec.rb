# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor service feedback", type: :system do
  before do
    given_i_am_authorized_as_a_user(
      create(:staff, :with_assess_permission, :with_support_console_permission),
    )
  end

  it "lists feedback newest first and links to its details" do
    given_there_are_feedback_submissions_with_different_times

    when_i_visit_the(:assessor_applications_page)
    and_i_click_the_service_feedback_link

    then_i_see_the(:assessor_feedback_submissions_page)
    and_i_see_the_feedback_ordered_newest_first
    and_i_see_a_download_feedback_link

    when_i_click_the_first_feedback_link

    then_i_see_the(:assessor_feedback_submission_page, id: @newest.id)
    and_i_see_the_feedback_details
  end

  it "shows a fallback when feedback has no comment" do
    given_there_is_a_feedback_submission_with_no_comment

    when_i_visit_the(
      :assessor_feedback_submission_page,
      id: @feedback_submission.id,
    )

    then_i_see_a_no_comment_fallback_message
  end

  it "truncates comments longer than 151 characters on the index" do
    given_there_is_a_feedback_submission_with_a_long_comment

    when_i_visit_the(:assessor_feedback_submissions_page)

    then_i_see_the_truncated_comment
  end

  it "filters feedback by submitted date and clears the selection" do
    given_there_are_feedback_submissions_with_various_dates

    when_i_visit_the(:assessor_feedback_submissions_page)
    and_i_fill_in_the_submitted_at_filter(
      from: Date.new(2024, 1, 10),
      to: Date.new(2024, 1, 20),
    )
    and_i_apply_the_filters

    then_i_see_only_the_feedback_within_the_date_range

    when_i_clear_the_filters

    then_i_see_all_the_feedback
  end

  it "shows date filter errors and preserves the entered dates" do
    when_i_visit_the(:assessor_feedback_submissions_page)
    and_i_fill_in_invalid_future_dates_in_the_filter
    and_i_apply_the_filters

    then_i_see_date_filter_errors
    and_i_see_the_invalid_dates_preserved
  end

  it "shows an empty state when there is no feedback" do
    when_i_visit_the(:assessor_feedback_submissions_page)

    then_i_see_the_empty_feedback_state
    and_i_do_not_see_a_download_feedback_link
  end

  private

  # Setup (given)

  def given_there_are_feedback_submissions_with_different_times
    @oldest =
      create_feedback_submission(
        application_status: "not_started",
        overall_experience: "dissatisfied",
        comment: "The oldest feedback",
        submitted_at: Time.zone.local(2024, 1, 10, 9, 15),
      )
    @newest =
      create_feedback_submission(
        application_status: "application_submitted",
        overall_experience: "highly_satisfied",
        comment: "The newest feedback",
        submitted_at: Time.zone.local(2024, 1, 15, 14, 30),
      )
  end

  def given_there_is_a_feedback_submission_with_no_comment
    @feedback_submission =
      create_feedback_submission(
        comment: nil,
        submitted_at: Time.zone.local(2024, 1, 15, 14, 30),
      )
  end

  def given_there_is_a_feedback_submission_with_a_long_comment
    create_feedback_submission(
      comment: "#{"a" * 150}bc",
      submitted_at: Time.zone.local(2024, 1, 15, 14, 30),
    )
  end

  def given_there_are_feedback_submissions_with_various_dates
    @before_range =
      create_feedback_submission(
        comment: "Before range",
        submitted_at: Time.zone.local(2024, 1, 5),
      )
    @within_range =
      create_feedback_submission(
        comment: "Within range",
        submitted_at: Time.zone.local(2024, 1, 15),
      )
    @after_range =
      create_feedback_submission(
        comment: "After range",
        submitted_at: Time.zone.local(2024, 1, 25),
      )
  end

  # Actions (when / and)

  def and_i_click_the_service_feedback_link
    assessor_applications_page.header.service_feedback_link.click
  end

  def when_i_click_the_first_feedback_link
    assessor_feedback_submissions_page.feedback_rows.first.id_link.click
  end

  def and_i_fill_in_the_submitted_at_filter(from:, to:)
    fill_in_submitted_at_filter(from:, to:)
  end

  def and_i_fill_in_invalid_future_dates_in_the_filter
    fill_in_submitted_at_filter(
      from: Date.current + 1.day,
      to: Date.current + 2.days,
    )
  end

  def and_i_apply_the_filters
    assessor_feedback_submissions_page.apply_filters.click
  end

  def when_i_clear_the_filters
    assessor_feedback_submissions_page.clear_filters.click
  end

  # Expectations (then / and)

  def and_i_see_the_feedback_ordered_newest_first
    expect(visible_feedback_ids).to eq(
      [formatted_id(@newest), formatted_id(@oldest)],
    )
  end

  def and_i_see_a_download_feedback_link
    expect(assessor_feedback_submissions_page).to have_download_feedback
  end

  def and_i_do_not_see_a_download_feedback_link
    expect(assessor_feedback_submissions_page).not_to have_download_feedback
  end

  def and_i_see_the_feedback_details
    expect(summary_value("ID")).to eq(formatted_id(@newest))
    expect(summary_value("Status")).to eq("Application submitted")
    expect(summary_value("Rating")).to eq("Highly satisfied")
    expect(summary_value("Submitted on")).to eq("15/01/2024\n14:30")
    expect(assessor_feedback_submission_page.comments).to have_text(
      "The newest feedback",
    )
  end

  def then_i_see_a_no_comment_fallback_message
    expect(assessor_feedback_submission_page.comments).to have_text(
      "No comment provided.",
    )
  end

  def then_i_see_the_truncated_comment
    expect(
      assessor_feedback_submissions_page.feedback_rows.first.comments.text,
    ).to eq("#{"a" * 150}…")
  end

  def then_i_see_only_the_feedback_within_the_date_range
    expect(visible_feedback_ids).to eq([formatted_id(@within_range)])
  end

  def then_i_see_all_the_feedback
    expect(visible_feedback_ids).to contain_exactly(
      formatted_id(@before_range),
      formatted_id(@within_range),
      formatted_id(@after_range),
    )
  end

  def then_i_see_date_filter_errors
    expect(assessor_feedback_submissions_page.error_summary).to have_content(
      "The date you want to filter from must be today or in the past",
    )
    expect(assessor_feedback_submissions_page.error_summary).to have_content(
      "The date you want to filter to must be today or in the past",
    )
  end

  def and_i_see_the_invalid_dates_preserved
    expect_filter_to_contain(
      from: Date.current + 1.day,
      to: Date.current + 2.days,
    )
  end

  def then_i_see_the_empty_feedback_state
    expect(assessor_feedback_submissions_page).to have_content(
      "No feedback found.",
    )
  end

  # Helpers

  def create_feedback_submission(attributes)
    FeedbackSubmission.create!(
      {
        application_status: "not_started",
        overall_experience: "highly_satisfied",
      }.merge(attributes),
    )
  end

  def formatted_id(feedback_submission)
    feedback_submission.id.to_s.rjust(4, "0")
  end

  def visible_feedback_ids
    assessor_feedback_submissions_page.feedback_rows.map do |row|
      row.id_link.text
    end
  end

  def summary_value(key)
    assessor_feedback_submission_page.summary_list.find_row(key:).value.text
  end

  def fill_in_submitted_at_filter(from:, to:)
    filter = assessor_feedback_submissions_page.submitted_at_filter
    filter.start_day.set(from.day)
    filter.start_month.set(from.month)
    filter.start_year.set(from.year)
    filter.end_day.set(to.day)
    filter.end_month.set(to.month)
    filter.end_year.set(to.year)
  end

  def expect_filter_to_contain(from:, to:)
    filter = assessor_feedback_submissions_page.submitted_at_filter
    expect(filter.start_day.value).to eq(from.day.to_s)
    expect(filter.start_month.value).to eq(from.month.to_s)
    expect(filter.start_year.value).to eq(from.year.to_s)
    expect(filter.end_day.value).to eq(to.day.to_s)
    expect(filter.end_month.value).to eq(to.month.to_s)
    expect(filter.end_year.value).to eq(to.year.to_s)
  end
end
