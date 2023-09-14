# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor verifying professional standing", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_an_admin_user
    given_there_is_an_application_form_with_professional_standing_request
  end

  it "verify" do
    when_i_visit_the(:assessor_application_page, reference:)
    and_i_click_professional_standing_task
    then_i_see_the(
      :assessor_professional_standing_request_page,
      reference:,
      assessment_id:,
    )
    and_the_request_lops_verification_status_is("NOT STARTED")
    and_the_record_lops_response_status_is("CANNOT START")

    when_i_click_request_lops_verification
    then_i_see_the(
      :assessor_request_professional_standing_request_page,
      reference:,
      assessment_id:,
    )
    and_i_submit_unchecked_on_the_request_form
    then_i_see_the(
      :assessor_professional_standing_request_page,
      reference:,
      assessment_id:,
    )
    and_the_request_lops_verification_status_is("NOT STARTED")
    and_the_record_lops_response_status_is("CANNOT START")

    when_i_click_request_lops_verification
    and_i_submit_checked_on_the_request_form
    then_i_see_the(
      :assessor_professional_standing_request_page,
      reference:,
      assessment_id:,
    )
    and_the_request_lops_verification_status_is("COMPLETED")
    and_the_record_lops_response_status_is("WAITING ON")

    when_i_click_record_lops_response
    then_i_see_the(
      :assessor_verify_professional_standing_request_page,
      reference:,
      assessment_id:,
    )
    and_i_submit_yes_on_the_verify_form
    then_i_see_the(
      :assessor_professional_standing_request_page,
      reference:,
      assessment_id:,
    )
    and_the_record_lops_response_status_is("COMPLETED")

    when_i_click_record_lops_response
    then_i_see_the(
      :assessor_verify_professional_standing_request_page,
      reference:,
      assessment_id:,
    )
    and_i_submit_no_on_the_verify_form
    then_i_see_the(
      :assessor_verify_failed_professional_standing_request_page,
      reference:,
      assessment_id:,
    )
    and_i_submit_an_internal_note
    then_i_see_the(
      :assessor_professional_standing_request_page,
      reference:,
      assessment_id:,
    )
    and_the_record_lops_response_status_is("REVIEW")
  end

  private

  def given_there_is_an_application_form_with_professional_standing_request
    application_form
  end

  def and_i_click_professional_standing_task
    assessor_application_page.verify_professional_standing_task.link.click
  end

  def when_i_click_request_lops_verification
    assessor_professional_standing_request_page.request_lops_verification_task.click
  end

  def when_i_click_record_lops_response
    assessor_professional_standing_request_page.record_lops_response_task.click
  end

  def and_the_request_lops_verification_status_is(status)
    expect(
      assessor_professional_standing_request_page
        .request_lops_verification_task
        .status_tag
        .text,
    ).to eq(status)
  end

  def and_the_record_lops_response_status_is(status)
    expect(
      assessor_professional_standing_request_page
        .record_lops_response_task
        .status_tag
        .text,
    ).to eq(status)
  end

  def and_i_submit_checked_on_the_request_form
    assessor_request_professional_standing_request_page.submit_checked
  end

  def and_i_submit_unchecked_on_the_request_form
    assessor_request_professional_standing_request_page.submit_unchecked
  end

  def and_i_submit_yes_on_the_verify_form
    assessor_verify_professional_standing_request_page.submit_yes
  end

  def and_i_submit_no_on_the_verify_form
    assessor_verify_professional_standing_request_page.submit_no
  end

  def and_i_submit_an_internal_note
    assessor_verify_failed_professional_standing_request_page.submit(
      note: "A note.",
    )
  end

  def application_form
    @application_form ||=
      begin
        application_form =
          create(:application_form, :waiting_on, statuses: %w[waiting_on_lops])
        create(
          :assessment,
          :with_professional_standing_request,
          application_form:,
        )
        application_form
      end
  end

  delegate :reference, to: :application_form

  def assessment_id
    application_form.assessment.id
  end
end
