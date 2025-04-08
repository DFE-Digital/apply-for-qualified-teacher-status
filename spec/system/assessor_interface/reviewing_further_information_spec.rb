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

  it "review accept" do
    when_i_visit_the(:assessor_application_page, reference:)
    and_i_click_review_requested_information
    then_i_see_the(
      :assessor_review_further_information_request_page,
      reference:,
      assessment_id:,
      id: further_information_request.id,
    )
    and_i_see_the_fi_responses

    when_i_mark_the_information_received_as_accepted
    then_i_see_the(:assessor_complete_assessment_page, reference:)
    and_i_see_an_award_qts_option
  end

  it "review all decline" do
    when_i_visit_the(:assessor_application_page, reference:)
    and_i_click_review_requested_information
    then_i_see_the(
      :assessor_review_further_information_request_page,
      reference:,
      assessment_id:,
      id: further_information_request.id,
    )
    and_i_see_the_fi_responses

    when_i_mark_the_information_received_as_decline
    then_i_see_the(
      :assessor_decline_further_information_request_page,
      reference:,
    )
    when_i_add_a_decline_note_and_submit

    then_i_see_the(:assessor_complete_assessment_page, reference:)
    and_i_see_a_decline_qts_option
  end

  it "review some accept and some decline" do
    when_i_visit_the(:assessor_application_page, reference:)
    and_i_click_review_requested_information
    then_i_see_the(
      :assessor_review_further_information_request_page,
      reference:,
      assessment_id:,
      id: further_information_request.id,
    )
    and_i_see_the_fi_responses

    when_i_mark_the_information_received_as_some_accepted_and_some_declined
    then_i_see_the(
      :assessor_decline_further_information_request_page,
      reference:,
    )
    when_i_add_a_decline_note_and_submit

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
      "We could not verify 1 or more references entered by the applicant for " \
        "#{application_form.work_histories.first.school_name}.",
    )
  end

  def when_i_mark_the_information_received_as_accepted
    assessor_review_further_information_request_page.submit_yes(
      items: further_information_request.items,
    )
  end

  def and_i_see_an_award_qts_option
    expect(
      assessor_complete_assessment_page.award_qts_pending_verifications,
    ).not_to be_nil
  end

  def when_i_mark_the_information_received_as_decline
    assessor_review_further_information_request_page.submit_no(
      items: further_information_request.items,
    )
  end

  def when_i_mark_the_information_received_as_some_accepted_and_some_declined
    assessor_review_further_information_request_page.find(
      "#assessor-interface-further-information-request-review-form-#{
        further_information_request.items.first.id
      }-decision-decline-field",
      visible: false,
    ).choose

    assessor_review_further_information_request_page.find(
      "#assessor-interface-further-information-request-review-form-#{
        further_information_request.items.second.id
      }-decision-accept-field",
      visible: false,
    ).choose

    assessor_review_further_information_request_page.find(
      "#assessor-interface-further-information-request-review-form-#{
        further_information_request.items.last.id
      }-decision-accept-field",
      visible: false,
    ).choose

    assessor_review_further_information_request_page.form.submit_button.click
  end

  def when_i_add_a_decline_note_and_submit
    assessor_decline_further_information_request_page.form.note_textarea.fill_in with:
      "Decline note."
    assessor_decline_further_information_request_page.form.submit_button.click
  end

  def and_i_see_a_decline_qts_option
    expect(assessor_complete_assessment_page.decline_qts).not_to be_nil
  end

  def and_i_do_not_see_the_review_further_information_form
    expect(
      assessor_review_further_information_request_page.form,
    ).not_to have_submit_button
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
