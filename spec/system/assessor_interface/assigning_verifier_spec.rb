# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assigning a verifier", type: :system do
  let(:assessor_user) do
    create(:staff, :with_assess_permission, name: "Assessor User")
  end
  let(:manager_user) do
    create(
      :staff,
      :with_reverse_decision_permission,
      :with_assess_permission,
      name: "Manager User",
    )
  end
  let(:original_verifier) { create(:staff, name: "Original Verifier") }

  it "assigns the verifier when awarded at the verify stage" do
    given_i_am_authorized_as_a_user(assessor_user)
    given_there_is_an_awardable_application_form_in_verify_stage
    given_i_can_request_trs_api

    when_i_visit_the(
      :assessor_complete_assessment_page,
      reference:,
      assessment_id:,
    )
    and_i_complete_the_award_flow

    when_i_click_on_overview_button
    then_the_verified_by_summary_shows(assessor_user.name)
  end

  it "does not change the verifier when awarded at the review stage" do
    given_i_am_authorized_as_a_user(assessor_user)
    given_there_is_an_awardable_application_form_in_review_stage(
      verifier: original_verifier,
    )
    given_i_can_request_trs_api

    when_i_visit_the(
      :assessor_complete_assessment_page,
      reference:,
      assessment_id:,
    )
    and_i_complete_the_award_flow

    when_i_click_on_overview_button
    then_the_verified_by_summary_shows(original_verifier.name)
  end

  it "resets the verifier when a decision is reversed and then awarded" do
    given_i_am_authorized_as_a_user(manager_user)
    given_there_is_an_awarded_application_form(verifier: original_verifier)
    given_i_can_request_trs_api

    when_i_visit_the(:assessor_application_page, reference:)
    when_i_click_on_reverse_decision
    when_i_visit_the(
      :assessor_reverse_decision_page,
      reference:,
      assessment_id:,
    )
    when_i_confirm_the_reversal

    when_i_visit_the(
      :assessor_complete_assessment_page,
      reference:,
      assessment_id:,
    )
    and_i_complete_the_award_flow

    when_i_click_on_overview_button
    then_the_verified_by_summary_shows(manager_user.name)
  end

  private

  def given_there_is_a_base_application_form
    @application_form =
      create(
        :application_form,
        :with_personal_information,
        :with_teaching_qualification,
        :submitted,
      )

    @assessment = create(:assessment, application_form: @application_form)
  end

  def given_there_is_an_awardable_application_form_in_verify_stage
    given_there_is_a_base_application_form
    @assessment.verify!
    @assessment.update!(induction_required: false)
    @application_form.update!(stage: "verification")
  end

  def given_there_is_an_awardable_application_form_in_review_stage(verifier:)
    given_there_is_a_base_application_form
    @assessment.review!
    @assessment.update!(induction_required: false)
    @application_form.update!(verifier:)
  end

  def given_there_is_an_awarded_application_form(verifier:)
    given_there_is_a_base_application_form
    work_history =
      create(:work_history, :completed, application_form: @application_form)
    create(
      :received_reference_request,
      assessment: @assessment,
      work_history: work_history,
      verify_passed: true,
    )
    @assessment.award!
    @assessment.update!(induction_required: false)
    @application_form.update!(verifier:)
  end

  def given_i_can_request_trs_api
    stub_request(
      :post,
      "https://test-teacher-qualifications-api.education.gov.uk/v3/trn-requests",
    ).to_return(
      body: '{"trn": "abcdef", "potential_duplicate": false}',
      headers: {
        "Content-Type" => "application/json",
      },
    )

    stub_request(
      :put,
      "https://test-teacher-qualifications-api.education.gov.uk/v3/persons/abcdef/routes-to-professional-statuses/#{reference}",
    ).to_return(
      status: 200,
      body: "",
      headers: {
        "Content-Type" => "application/json",
      },
    )
  end

  def and_i_complete_the_award_flow
    assessor_complete_assessment_page.award_qts.input.choose
    assessor_complete_assessment_page.continue_button.click

    assessor_declare_assessment_recommendation_page
      .form
      .declaration_checkbox
      .click
    assessor_declare_assessment_recommendation_page.form.submit_button.click

    assessor_age_range_subjects_assessment_recommendation_award_page.continue_button.click

    assessor_confirm_assessment_recommendation_page
      .form
      .true_radio_item
      .input
      .click
    assessor_confirm_assessment_recommendation_page.form.continue_button.click
  end

  def when_i_click_on_reverse_decision
    assessor_application_page.task_lists.last.click_on("Reverse decision")
  end

  def when_i_confirm_the_reversal
    assessor_reverse_decision_page.form.submit_button.click
  end

  def when_i_click_on_overview_button
    assessor_application_status_page.button_group.overview_button.click
  end

  def then_the_verified_by_summary_shows(name)
    expect(assessor_application_page.verified_by_summary.value).to have_text(
      name,
    )
  end

  def reference
    @application_form.reference
  end

  def assessment_id
    @assessment.id
  end
end
