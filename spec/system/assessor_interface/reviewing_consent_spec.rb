# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor reviewing references", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_failed_consent
  end

  it "sends for review" do
    when_i_visit_the(:assessor_application_page, reference:)
    then_i_see_the(:assessor_application_page, reference:)

    when_i_click_on_verification_decision
    then_i_see_the(:assessor_complete_assessment_page, reference:)

    when_i_select_send_for_review
    then_i_see_the(:assessor_assessment_recommendation_review_page, reference:)

    when_i_click_continue_from_review
    then_i_see_the(:assessor_application_status_page, reference:)

    when_i_click_on_overview_button
    then_i_see_the(:assessor_application_page, reference:)

    when_i_click_on_review_verifications
    then_i_see_the(
      :assessor_review_verifications_page,
      reference:,
      assessment_id:,
    )
    and_i_see_the_consent_not_started

    when_i_click_on_the_consent
    then_i_see_the(
      :assessor_review_consent_request_page,
      reference:,
      assessment_id:,
    )
    and_i_see_the_overdue_status

    when_i_submit_no_on_the_review_form
    then_i_see_the(
      :assessor_review_verifications_page,
      reference:,
      assessment_id:,
    )
    and_i_see_the_consent_rejected

    when_i_click_on_back_to_overview
    then_i_see_the(:assessor_application_page, reference:)

    when_i_click_on_assessment_decision
    then_i_see_the(
      :assessor_complete_assessment_page,
      reference:,
      assessment_id:,
    )
  end

  private

  def given_there_is_an_application_form_with_failed_consent
    application_form
  end

  def when_i_click_on_verification_decision
    assessor_application_page.verification_decision_task.click
  end

  def when_i_select_send_for_review
    assessor_complete_assessment_page.send_for_review.choose
    assessor_complete_assessment_page.continue_button.click
  end

  def when_i_click_continue_from_review
    assessor_assessment_recommendation_review_page.continue_button.click
  end

  def when_i_click_on_overview_button
    assessor_application_status_page.button_group.overview_button.click
  end

  def when_i_click_on_review_verifications
    assessor_application_page.review_verifications_task.click
  end

  def when_i_click_on_assessment_decision
    assessor_application_page.assessment_decision_task.click
  end

  def when_i_click_on_the_consent
    consent_task_item.click
  end

  def and_i_see_the_overdue_status
    expect(assessor_review_verifications_page).to have_content(
      "This consent’s status has changed from OVERDUE to RECEIVED",
    )
  end

  def when_i_submit_no_on_the_review_form
    assessor_review_reference_request_page.submit_no(note: "A note.")
  end

  def when_i_click_on_back_to_overview
    assessor_review_verifications_page.back_to_overview_button.click
  end

  def and_i_see_the_consent_not_started
    expect(consent_task_item.status_tag.text).to eq("NOT STARTED")
  end

  def and_i_see_the_consent_rejected
    expect(consent_task_item.status_tag.text).to eq("REJECTED")
  end

  def consent_task_item
    assessor_review_verifications_page.task_list.find_item(
      "BSc Teaching (University of Teaching)",
    )
  end

  def application_form
    @application_form ||=
      begin
        application_form = create(:application_form, :submitted)
        qualification =
          create(
            :qualification,
            :completed,
            application_form:,
            title: "BSc Teaching",
            institution_name: "University of Teaching",
          )
        assessment = create(:assessment, :verify, application_form:)
        create(
          :consent_request,
          :received,
          :expired,
          assessment:,
          verify_passed: false,
          qualification:,
        )
        application_form
      end
  end

  delegate :reference, to: :application_form

  def assessment_id
    application_form.assessment.id
  end
end
