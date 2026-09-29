# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor service feedback", type: :system do
  before do
    given_i_am_authorized_as_a_user(
      create(:staff, :with_assess_permission, :with_support_console_permission),
    )
  end

  it "lists feedback newest first and links to its details" do
    oldest =
      create_feedback_submission(
        application_status: "not_started",
        overall_experience: "dissatisfied",
        comment: "The oldest feedback",
        submitted_at: Time.zone.local(2024, 1, 10, 9, 15),
      )
    newest =
      create_feedback_submission(
        application_status: "application_submitted",
        overall_experience: "highly_satisfied",
        comment: "The newest feedback",
        submitted_at: Time.zone.local(2024, 1, 15, 14, 30),
      )

    when_i_visit_the(:assessor_applications_page)
    assessor_applications_page.header.service_feedback_link.click

    then_i_see_the(:assessor_feedback_submissions_page)
    expect(visible_feedback_ids).to eq(
      [formatted_id(newest), formatted_id(oldest)],
    )
    expect(assessor_feedback_submissions_page).to have_download_feedback

    assessor_feedback_submissions_page.feedback_rows.first.id_link.click

    then_i_see_the(:assessor_feedback_submission_page, id: newest.id)
    expect(summary_value("ID")).to eq(formatted_id(newest))
    expect(summary_value("Status")).to eq("Application submitted")
    expect(summary_value("Rating")).to eq("Highly satisfied")
    expect(summary_value("Submitted on")).to eq("15/01/2024\n14:30")
    expect(assessor_feedback_submission_page.comments).to have_text(
      "The newest feedback",
    )
  end

  it "shows a fallback when feedback has no comment" do
    feedback_submission =
      create_feedback_submission(
        comment: nil,
        submitted_at: Time.zone.local(2024, 1, 15, 14, 30),
      )

    when_i_visit_the(
      :assessor_feedback_submission_page,
      id: feedback_submission.id,
    )

    expect(assessor_feedback_submission_page.comments).to have_text(
      "No comment provided.",
    )
  end

  it "filters feedback by submitted date and clears the selection" do
    before_range =
      create_feedback_submission(
        comment: "Before range",
        submitted_at: Time.zone.local(2024, 1, 5),
      )
    within_range =
      create_feedback_submission(
        comment: "Within range",
        submitted_at: Time.zone.local(2024, 1, 15),
      )
    after_range =
      create_feedback_submission(
        comment: "After range",
        submitted_at: Time.zone.local(2024, 1, 25),
      )

    when_i_visit_the(:assessor_feedback_submissions_page)
    fill_in_submitted_at_filter(
      from: Date.new(2024, 1, 10),
      to: Date.new(2024, 1, 20),
    )
    assessor_feedback_submissions_page.apply_filters.click

    expect(visible_feedback_ids).to eq([formatted_id(within_range)])

    assessor_feedback_submissions_page.clear_filters.click

    expect(visible_feedback_ids).to contain_exactly(
      formatted_id(before_range),
      formatted_id(within_range),
      formatted_id(after_range),
    )
  end

  it "shows an empty state when there is no feedback" do
    when_i_visit_the(:assessor_feedback_submissions_page)

    expect(assessor_feedback_submissions_page).to have_content(
      "No feedback found.",
    )
    expect(assessor_feedback_submissions_page).not_to have_download_feedback
  end

  private

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
end
