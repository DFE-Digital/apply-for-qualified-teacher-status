# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor completing assessment", type: :system do
  it "award" do
    given_the_service_is_open
    given_i_am_authorized_as_a_user(assessor)
    given_there_is_an_awardable_application_form
    given_i_can_request_dqt_api

    when_i_visit_the(:complete_assessment_page, application_id:, assessment_id:)

    when_i_select_award_qts
    and_i_click_continue
    then_i_see_the(:confirm_assessment_page, application_id:, assessment_id:)

    when_i_confirm_declaration
    then_the_application_form_is_awarded
  end

  it "decline" do
    given_the_service_is_open
    given_i_am_authorized_as_a_user(assessor)
    given_there_is_a_declinable_application_form

    when_i_visit_the(:complete_assessment_page, application_id:, assessment_id:)

    when_i_select_decline_qts
    and_i_click_continue
    then_i_see_the(:confirm_assessment_page, application_id:, assessment_id:)
    and_i_see_failure_reasons

    when_i_confirm_declaration
    then_the_application_form_is_declined
  end

  private

  def given_there_is_an_awardable_application_form
    @application_form ||=
      create(
        :application_form,
        :with_personal_information,
        :with_completed_qualification,
        :submitted,
      )

    assessment = create(:assessment, application_form:)

    create(:assessment_section, :personal_information, :passed, assessment:)
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

    create(:assessment_section, :personal_information, :failed, assessment:)
  end

  def given_i_can_request_dqt_api
    uri_template =
      Addressable::Template.new(
        "https://test-teacher-qualifications-api.education.gov.uk/v2/trn-requests/{request_id}",
      )
    stub_request(:put, uri_template).to_return(
      body: "{}",
      headers: {
        "Content-Type" => "application/json",
      },
    )
  end

  def when_i_visit_the_complete_assessment_page
    complete_assessment_page.load(application_id: application_form.id)
  end

  def then_i_see_the_complete_assessment_form
    expect(complete_assessment_page.award_qts).to be_visible
    expect(complete_assessment_page.decline_qts).to be_visible
  end

  def when_i_select_award_qts
    complete_assessment_page.award_qts.input.choose
  end

  def when_i_select_decline_qts
    complete_assessment_page.decline_qts.input.choose
  end

  def and_i_see_failure_reasons
    failure_reason_item =
      confirm_assessment_page.failure_reason_lists.first.items.first
    expect(failure_reason_item.heading.text).to eq("Failure Reason")
    expect(failure_reason_item.note.text).to eq("Notes.")
  end

  def when_i_confirm_declaration
    confirm_assessment_page.form.confirm_declaration.click
    confirm_assessment_page.form.submit_button.click
  end

  def then_the_application_form_is_awarded
    expect(assessor_application_page.overview.status.text).to eq("AWARDED")
  end

  def then_the_application_form_is_declined
    expect(assessor_application_page.overview.status.text).to eq("DECLINED")
  end

  def application_id
    application_form.id
  end

  def assessment_id
    application_form.assessment.id
  end

  def assessor
    @assessor ||= create(:staff, :confirmed)
  end

  attr_reader :application_form
end
