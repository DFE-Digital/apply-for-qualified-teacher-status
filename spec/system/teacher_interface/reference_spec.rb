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
      dates_response: true,
      hours_response: true,
      children_response: true,
      lessons_response: true,
      reports_response: true,
    )

    when_i_visit_the(:teacher_check_reference_request_answers_page, slug:)
    then_i_see_the(:teacher_check_reference_request_answers_page, slug:)
    and_i_see_the_answers

    reference_request.update!(state: "received", received_at: Time.zone.now)

    when_i_visit_the(:teacher_reference_received_page, slug:)
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

  def and_i_see_the_answers
    expect(
      teacher_check_reference_request_answers_page.summary_list,
    ).to be_visible
  end

  def and_i_see_the_confirmation_panel
    expect(teacher_reference_received_page.confirmation_panel).to be_visible
  end

  def reference_request
    @reference_request ||= create(:reference_request, :requested)
  end

  delegate :slug, to: :reference_request
end
