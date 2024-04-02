# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor completing assessment", type: :system do
  let(:notify_key) { "notify-key" }
  let(:notify_client) do
    double(generate_template_preview: notify_template_preview)
  end
  let(:notify_template_preview) { double(html: "I am an email") }
  let(:assessor_user) do
    create(:staff, :with_assess_permission, name: "Authorized User")
  end

  around do |example|
    ClimateControl.modify GOVUK_NOTIFY_API_KEY: notify_key do
      example.run
    end
  end

  before do
    allow(Notifications::Client).to receive(:new).with(notify_key).and_return(
      notify_client,
    )
  end

  it "award" do
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_awardable_application_form(%i[old_regs])
    given_i_can_request_dqt_api

    when_i_visit_the(
      :assessor_complete_assessment_page,
      reference:,
      assessment_id:,
    )

    when_i_select_award_qts
    and_i_click_continue
    then_i_see_the(
      :assessor_declare_assessment_recommendation_page,
      reference:,
      assessment_id:,
      recommendation: "award",
    )

    when_i_check_declaration
    then_i_see_the(
      :assessor_age_range_subjects_assessment_recommendation_award_page,
    )
    and_i_see_the_age_range_subjects

    when_i_click_change_age_range_minimum
    then_i_see_the(
      :assessor_edit_age_range_subjects_assessment_recommendation_award_page,
    )

    when_i_click_continue
    then_i_see_the(
      :assessor_age_range_subjects_assessment_recommendation_award_page,
    )
    and_i_continue_from_age_range_subjects

    then_i_see_the(
      :assessor_preview_assessment_recommendation_page,
      reference:,
      assessment_id:,
      recommendation: "award",
    )

    when_i_send_the_email
    then_i_see_the(
      :assessor_confirm_assessment_recommendation_page,
      reference:,
      assessment_id:,
      recommendation: "award",
    )

    when_i_check_confirmation
    then_i_see_the(:assessor_application_status_page, reference:)

    when_i_click_on_overview_button
    then_the_application_form_is_awarded
  end

  it "verify" do
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_awardable_application_form_with_work_history

    when_i_visit_the(
      :assessor_complete_assessment_page,
      reference:,
      assessment_id:,
    )

    when_i_select_award_qts_pending_verifications
    and_i_click_continue
    then_i_see_the(
      :assessor_verify_qualifications_assessment_recommendation_verify_page,
      reference:,
      assessment_id:,
    )

    when_i_select_yes_verify_qualifications
    then_i_see_the(
      :assessor_qualification_requests_assessment_recommendation_verify_page,
      reference:,
      assessment_id:,
    )

    when_i_select_the_qualifications
    then_i_see_the(
      :assessor_professional_standing_assessment_recommendation_verify_page,
      reference:,
      assessment_id:,
    )

    when_i_select_yes_verify_professional_standing
    then_i_see_the(
      :assessor_reference_requests_assessment_recommendation_verify_page,
      reference:,
      assessment_id:,
    )

    when_i_select_the_work_histories
    then_i_see_the(
      :assessor_assessment_recommendation_verify_page,
      reference:,
      assessment_id:,
    )

    when_i_select_submit_verification_requests
    then_i_see_the(:assessor_application_status_page, reference:)

    when_i_click_on_overview_button
    then_the_application_form_is_waiting_on
  end

  it "verify with reduced evidence" do
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_awardable_application_form_with_reduced_evidence

    when_i_visit_the(
      :assessor_complete_assessment_page,
      reference:,
      assessment_id:,
    )

    when_i_select_award_qts_pending_verifications
    and_i_click_continue
    then_i_see_the(
      :assessor_verify_qualifications_assessment_recommendation_verify_page,
      reference:,
      assessment_id:,
    )

    when_i_select_yes_verify_qualifications
    then_i_see_the(
      :assessor_qualification_requests_assessment_recommendation_verify_page,
      reference:,
      assessment_id:,
    )

    when_i_select_the_qualifications
    then_i_see_the(
      :assessor_assessment_recommendation_verify_page,
      reference:,
      assessment_id:,
    )

    when_i_select_submit_verification_requests
    then_i_see_the(:assessor_application_status_page, reference:)

    when_i_click_on_overview_button
    then_the_application_form_is_verification_in_progress
  end

  it "decline" do
    given_i_am_authorized_as_an_assessor_user
    given_there_is_a_declinable_application_form

    when_i_visit_the(
      :assessor_complete_assessment_page,
      reference:,
      assessment_id:,
    )

    when_i_select_decline_qts
    and_i_click_continue
    then_i_see_the(
      :assessor_declare_assessment_recommendation_page,
      reference:,
      assessment_id:,
      recommendation: "decline",
    )
    and_i_see_failure_reasons

    when_i_check_declaration
    then_i_see_the(
      :assessor_preview_assessment_recommendation_page,
      reference:,
      assessment_id:,
      recommendation: "decline",
    )

    when_i_send_the_email
    then_i_see_the(
      :assessor_confirm_assessment_recommendation_page,
      reference:,
      assessment_id:,
      recommendation: "decline",
    )

    when_i_check_confirmation
    then_i_see_the(:assessor_application_status_page, reference:)

    when_i_click_on_overview_button
    then_the_application_form_is_declined

    and_i_click_view_timeline
    then_i_see_application_declined
  end

  private

  def given_there_is_an_awardable_application_form(traits = [])
    @application_form ||=
      create(
        :application_form,
        :with_personal_information,
        :with_teaching_qualification,
        :submitted,
        *traits,
        reduced_evidence_accepted: false,
      )

    assessment =
      create(
        :assessment,
        application_form:,
        age_range_min: 8,
        age_range_max: 11,
        subjects: %w[mathematics],
      )

    create(:assessment_section, :personal_information, :passed, assessment:)
  end

  def given_there_is_an_awardable_application_form_with_work_history
    given_there_is_an_awardable_application_form
    create(:work_history, :completed, application_form:)
  end

  def given_there_is_an_awardable_application_form_with_reduced_evidence
    given_there_is_an_awardable_application_form
    application_form.update!(reduced_evidence_accepted: true)
  end

  def given_there_is_a_declinable_application_form
    @application_form ||=
      create(
        :application_form,
        :with_personal_information,
        :submitted,
        :with_assessment,
      )

    assessment = create(:assessment, application_form:)

    create(
      :assessment_section,
      :personal_information,
      :failed,
      selected_failure_reasons: [
        build(
          :selected_failure_reason,
          assessor_feedback: @assessor_feedback = "Note.",
          key: @key = "applicant_already_qts",
        ),
      ],
      assessment:,
    )
  end

  def given_i_can_request_dqt_api
    uri_template =
      Addressable::Template.new(
        "https://test-teacher-qualifications-api.education.gov.uk/v2/trn-requests/{request_id}",
      )
    stub_request(:put, uri_template).to_return(
      body: '{"trn": "abcdef", "potential_duplicate": false}',
      headers: {
        "Content-Type" => "application/json",
      },
    )
  end

  def when_i_select_award_qts
    assessor_complete_assessment_page.award_qts.input.choose
  end

  def when_i_select_award_qts_pending_verifications
    assessor_complete_assessment_page
      .award_qts_pending_verifications
      .input
      .choose
  end

  def when_i_select_decline_qts
    assessor_complete_assessment_page.decline_qts.input.choose
  end

  def and_i_see_the_age_range_subjects
    rows =
      assessor_age_range_subjects_assessment_recommendation_award_page.summary_list.rows

    expect(rows.count).to eq(3)

    expect(rows.first.key.text).to eq("Minimum age")
    expect(rows.first.value.text).to eq("8")

    expect(rows.second.key.text).to eq("Maximum age")
    expect(rows.second.value.text).to eq("11")

    expect(rows.third.key.text).to eq("Subject")
    expect(rows.third.value.text).to eq("Mathematics")
  end

  def when_i_click_change_age_range_minimum
    assessor_age_range_subjects_assessment_recommendation_award_page
      .summary_list
      .rows
      .first
      .actions
      .link
      .click
  end

  def and_i_continue_from_age_range_subjects
    assessor_age_range_subjects_assessment_recommendation_award_page.continue_button.click
  end

  def and_i_see_failure_reasons
    failure_reason_item =
      assessor_declare_assessment_recommendation_page
        .failure_reason_lists
        .first
        .items
        .first
    expect(failure_reason_item.heading.text).to eq(
      "The applicant already holds QTS and induction exemption.",
    )
    expect(failure_reason_item.note.text).to eq("Note.")
  end

  def when_i_check_declaration
    assessor_declare_assessment_recommendation_page
      .form
      .declaration_checkbox
      .click
    assessor_declare_assessment_recommendation_page.form.submit_button.click
  end

  def when_i_select_yes_verify_qualifications
    assessor_verify_qualifications_assessment_recommendation_verify_page
      .form
      .true_radio_item
      .choose
    assessor_verify_qualifications_assessment_recommendation_verify_page
      .form
      .submit_button
      .click
  end

  def when_i_select_the_qualifications
    form =
      assessor_qualification_requests_assessment_recommendation_verify_page.form

    form.qualification_checkboxes.first.click
    form.qualifications_assessor_note_textarea.fill_in with: "A note."
    form.submit_button.click
  end

  def when_i_select_yes_verify_professional_standing
    assessor_professional_standing_assessment_recommendation_verify_page
      .form
      .true_radio_item
      .choose
    assessor_professional_standing_assessment_recommendation_verify_page
      .form
      .submit_button
      .click
  end

  def when_i_select_the_work_histories
    form =
      assessor_reference_requests_assessment_recommendation_verify_page.form

    form.work_history_checkboxes.first.click
    form.submit_button.click
  end

  def when_i_select_submit_verification_requests
    assessor_assessment_recommendation_verify_page.submit_button.click
  end

  def when_i_send_the_email
    assessor_preview_assessment_recommendation_page.send_button.click
  end

  def when_i_check_confirmation
    assessor_confirm_assessment_recommendation_page
      .form
      .true_radio_item
      .input
      .click
    assessor_confirm_assessment_recommendation_page.form.continue_button.click
  end

  def when_i_click_on_overview_button
    assessor_application_status_page.button_group.overview_button.click
  end

  def then_the_application_form_is_awarded
    expect(assessor_application_page.status_summary.value).to have_text(
      "AWARDED",
    )
  end

  def then_the_application_form_is_waiting_on
    expect(assessor_application_page.status_summary.value.text).to include(
      "WAITING ON",
    )
  end

  def then_the_application_form_is_verification_in_progress
    expect(assessor_application_page.status_summary.value.text).to include(
      "VERIFICATION IN PROGRESS",
    )
  end

  def then_the_application_form_is_declined
    expect(assessor_application_page.status_summary.value).to have_text(
      "DECLINED",
    )
  end

  def and_i_click_view_timeline
    assessor_application_page.click_link(
      "View timeline of this applications actions",
    )
  end

  def then_i_see_application_declined
    declined_timeline_event =
      assessor_timeline_page.timeline_items.find do |timeline_event|
        timeline_event.title.text.include?("Application declined")
      end

    expect(declined_timeline_event).to_not be_nil
  end

  delegate :reference, to: :application_form

  def assessment_id
    application_form.assessment.id
  end

  attr_reader :application_form
end
