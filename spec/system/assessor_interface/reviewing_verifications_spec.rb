# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor reviewing verifications", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_failed_verifications
  end

  it "sends for review" do
    when_i_visit_the(:assessor_application_page, application_form_id:)
    then_i_see_the(:assessor_application_page, application_form_id:)

    when_i_click_on_verification_decision
    then_i_see_the(:assessor_application_page, application_form_id:)

    when_i_click_on_review_verifications
    then_i_see_the(
      :assessor_review_verifications_page,
      application_form_id:,
      assessment_id:,
    )
    and_i_see_the_lops_not_started

    when_i_click_on_lops
    then_i_see_the(
      :assessor_review_professional_standing_request_page,
      application_form_id:,
      assessment_id:,
    )

    when_i_fill_in_the_review_lops_form
    then_i_see_the(
      :assessor_review_verifications_page,
      application_form_id:,
      assessment_id:,
    )
    and_i_see_the_lops_accepted

    when_i_click_on_back_to_overview
    then_i_see_the(:assessor_application_page, application_form_id:)

    when_i_click_on_assessment_decision
    then_i_see_the(
      :assessor_complete_assessment_page,
      application_form_id:,
      assessment_id:,
    )
  end

  private

  def given_there_is_an_application_form_with_failed_verifications
    application_form
  end

  def when_i_click_on_verification_decision
    assessor_application_page.verification_decision_task.click

    # TODO: review functionality is not built yet, this page can never be reached
    application_form.assessment.review!

    # TODO: reload the page
    when_i_visit_the(:assessor_application_page, application_form_id:)
  end

  def when_i_click_on_review_verifications
    assessor_application_page.review_verifications_task.click
  end

  def when_i_click_on_assessment_decision
    assessor_application_page.assessment_decision_task.click
  end

  def when_i_click_on_lops
    assessor_review_verifications_page.rows.first.link.click
  end

  def when_i_fill_in_the_review_lops_form
    form = assessor_review_professional_standing_request_page.form

    form.yes_radio_item.choose
    form.submit_button.click
  end

  def when_i_click_on_back_to_overview
    assessor_review_verifications_page.back_to_overview_button.click
  end

  def and_i_see_the_lops_not_started
    expect(assessor_review_verifications_page.rows.first.tag.text).to eq(
      "NOT STARTED",
    )
  end

  def and_i_see_the_lops_accepted
    expect(assessor_review_verifications_page.rows.first.tag.text).to eq(
      "ACCEPTED",
    )
  end

  def application_form
    @application_form ||=
      create(:application_form, :submitted).tap do |application_form|
        assessment =
          create(
            :assessment,
            :verify,
            application_form:,
            induction_required: false,
          )
        create(
          :professional_standing_request,
          :received,
          assessment:,
          verify_passed: false,
        )
      end
  end

  delegate :id, to: :application_form, prefix: true

  def assessment_id
    application_form.assessment.id
  end
end
