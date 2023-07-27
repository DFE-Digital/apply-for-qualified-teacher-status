# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor reviewing further information", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_failure_reasons
    given_there_is_further_information_received
  end

  it "review complete" do
    when_i_visit_the(:assessor_application_page, application_id:)
    and_i_click_review_requested_information
    then_i_see_the(
      :review_further_information_request_page,
      application_id:,
      assessment_id:,
      further_information_request_id:,
    )
    and_i_see_the_check_your_answers_items

    when_i_mark_the_section_as_complete
    then_i_see_the(:complete_assessment_page, application_id:)
    and_i_see_an_award_qts_option
  end

  it "review incomplete" do
    when_i_visit_the(:assessor_application_page, application_id:)
    and_i_click_review_requested_information
    then_i_see_the(
      :review_further_information_request_page,
      application_id:,
      assessment_id:,
      further_information_request_id:,
    )
    and_i_see_the_check_your_answers_items

    when_i_mark_the_section_as_incomplete
    then_i_see_the(:complete_assessment_page, application_id:)
    and_i_see_a_decline_qts_option
  end

  it "further information request passed and assessment finished" do
    further_information_request.reviewed!(true)
    further_information_request.assessment.award!

    when_i_visit_the(:assessor_application_page, application_id:)
    and_i_click_review_requested_information
    then_i_see_the(
      :review_further_information_request_page,
      application_id:,
      assessment_id:,
      further_information_request_id:,
    )
    and_i_see_the_check_your_answers_items
    and_i_do_not_see_the_review_further_information_form
  end

  private

  def given_there_is_an_application_form_with_failure_reasons
    application_form
  end

  def given_there_is_further_information_received
    further_information_request
  end

  def and_i_click_review_requested_information
    assessor_application_page.review_requested_information_task.link.click
  end

  def and_i_see_the_check_your_answers_items
    rows =
      review_further_information_request_page.summary_lists.flat_map(&:rows)

    expect(rows.count).to eq(8)

    expect(rows.first.key.text).to eq(
      "Tell us more about the subjects you can teach",
    )

    expect(rows.last.key.text).to eq("Upload your identity document")
  end

  def when_i_mark_the_section_as_complete
    review_further_information_request_page.form.yes_radio_item.input.click
    review_further_information_request_page.form.continue_button.click
  end

  def and_i_see_an_award_qts_option
    expect(complete_assessment_page.award_qts).to_not be_nil
  end

  def when_i_mark_the_section_as_incomplete
    review_further_information_request_page.form.no_radio_item.input.click
    review_further_information_request_page.form.failure_reason_textarea.fill_in with:
      "Failure reason"
    review_further_information_request_page.form.continue_button.click
  end

  def and_i_see_a_decline_qts_option
    expect(complete_assessment_page.decline_qts).to_not be_nil
  end

  def and_i_do_not_see_the_review_further_information_form
    expect(review_further_information_request_page).not_to have_form
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :with_personal_information,
        :submitted,
      ).tap do |application_form|
        assessment =
          create(:assessment, :request_further_information, application_form:)
        create(:assessment_section, :qualifications, :failed, assessment:)
      end
  end

  def further_information_request
    @further_information_request ||=
      create(
        :further_information_request,
        :received,
        :with_items,
        assessment: application_form.assessment,
      )
  end

  def application_id
    application_form.id
  end

  def assessment_id
    application_form.assessment.id
  end

  def further_information_request_id
    further_information_request.id
  end
end
