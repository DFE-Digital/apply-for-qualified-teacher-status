# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor reviewing further information", type: :system do
  before do
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_failure_reasons
    given_there_is_further_information_received
  end

  it "does not allow any access if user is archived" do
    given_i_am_authorized_as_an_archived_assessor_user

    when_i_visit_the(
      :assessor_review_further_information_request_page,
      reference:,
      assessment_id:,
      id: further_information_request.id,
    )
    then_i_see_the_forbidden_page
  end

  it "review complete" do
    when_i_visit_the(:assessor_application_page, reference:)
    and_i_click_review_requested_information
    then_i_see_the(
      :assessor_review_further_information_request_page,
      reference:,
      assessment_id:,
      id: further_information_request.id,
    )
    and_i_see_the_fi_responses

    when_i_mark_the_section_as_complete
    then_i_see_the(:assessor_complete_assessment_page, reference:)
    and_i_see_an_award_qts_option
  end

  it "review incomplete" do
    when_i_visit_the(:assessor_application_page, reference:)
    and_i_click_review_requested_information
    then_i_see_the(
      :assessor_review_further_information_request_page,
      reference:,
      assessment_id:,
      id: further_information_request.id,
    )
    and_i_see_the_fi_responses

    when_i_mark_the_section_as_incomplete
    then_i_see_the(:assessor_complete_assessment_page, reference:)
    and_i_see_a_decline_qts_option
  end

  it "further information request passed and assessment finished" do
    further_information_request.update!(review_passed: true)
    further_information_request.assessment.award!

    when_i_visit_the(:assessor_application_page, reference:)
    and_i_click_review_requested_information
    then_i_see_the(
      :assessor_review_further_information_request_page,
      reference:,
      assessment_id:,
      id: further_information_request.id,
    )
    and_i_see_the_fi_responses
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
    assessor_application_page.review_requested_information_task.click
  end

  def and_i_see_the_fi_responses
    items = assessor_review_further_information_request_page.summary_cards

    expect(items.count).to eq(3)

    expect(items.first).to have_content(
      "The ID document is illegible or in a format that we cannot accept.",
    )
    expect(items.second).to have_content(
      "Subjects entered are acceptable for QTS, but the uploaded qualifications do not match them.",
    )
    expect(items.last).to have_content(
      "We could not verify 1 or more references entered by the applicant.",
    )
  end

  def when_i_mark_the_section_as_complete
    assessor_review_further_information_request_page.submit_yes
  end

  def and_i_see_an_award_qts_option
    expect(
      assessor_complete_assessment_page.award_qts_pending_verifications,
    ).not_to be_nil
  end

  def when_i_mark_the_section_as_incomplete
    assessor_review_further_information_request_page.submit_no(
      note: "Failure reason",
    )
  end

  def and_i_see_a_decline_qts_option
    expect(assessor_complete_assessment_page.decline_qts).not_to be_nil
  end

  def and_i_do_not_see_the_review_further_information_form
    expect(assessor_review_further_information_request_page).not_to have_form
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :submitted,
        :with_personal_information,
        :with_work_history,
      ).tap do |application_form|
        assessment =
          create(:assessment, :request_further_information, application_form:)
        create(:assessment_section, :qualifications, :failed, assessment:)
      end
  end

  def further_information_request
    @further_information_request ||=
      create(
        :received_further_information_request,
        :with_items,
        assessment: application_form.assessment,
      ).tap do |further_information_request|
        further_information_request.items.each do |item|
          create :selected_failure_reason,
                 assessment_section: application_form.assessment.sections.first,
                 key: item.failure_reason_key
        end
      end
  end

  delegate :reference, to: :application_form

  def assessment_id
    application_form.assessment.id
  end
end
