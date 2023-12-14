# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor reviewing qualifications", type: :system do
  before do
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_failed_qualifications
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
    and_i_see_the_qualification_rejected

    when_i_click_on_the_qualification
    then_i_see_the(
      :assessor_review_qualification_request_page,
      reference:,
      assessment_id:,
    )

    when_i_submit_yes_on_the_review_form
    then_i_see_the(
      :assessor_review_verifications_page,
      reference:,
      assessment_id:,
    )
    and_i_see_the_qualification_accepted

    when_i_click_on_the_qualification
    then_i_see_the(
      :assessor_review_qualification_request_page,
      reference:,
      assessment_id:,
    )

    when_i_submit_no_on_the_review_form
    then_i_see_the(
      :assessor_review_verifications_page,
      reference:,
      assessment_id:,
    )
    and_i_see_the_qualification_rejected

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

  def given_there_is_an_application_form_with_failed_qualifications
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

  def when_i_click_on_the_qualification
    assessor_review_verifications_page.task_list.click_item("BSc Teaching")
  end

  def when_i_submit_yes_on_the_review_form
    assessor_review_qualification_request_page.submit_yes
  end

  def when_i_submit_no_on_the_review_form
    assessor_review_qualification_request_page.submit_no(note: "A note.")
  end

  def when_i_click_on_back_to_overview
    assessor_review_verifications_page.back_to_overview_button.click
  end

  def and_i_see_the_qualification_accepted
    item =
      assessor_review_verifications_page.task_list.find_item("BSc Teaching")
    expect(item.status_tag.text).to eq("Accepted")
  end

  def and_i_see_the_qualification_rejected
    item =
      assessor_review_verifications_page.task_list.find_item("BSc Teaching")
    expect(item.status_tag.text).to eq("Rejected")
  end

  def application_form
    @application_form ||=
      create(:application_form, :submitted).tap do |application_form|
        assessment = create(:assessment, :verify, application_form:)
        qualification =
          create(:qualification, application_form:, title: "BSc Teaching")
        create(
          :received_qualification_request,
          assessment:,
          qualification:,
          review_passed: false,
          verify_passed: false,
        )
      end
  end

  delegate :reference, to: :application_form

  def assessment_id
    application_form.assessment.id
  end
end
