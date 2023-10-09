# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor verifying professional standing", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user_with_verify_permission
    given_there_is_an_application_form_with_professional_standing_request
  end

  it "Request lops verification" do
    when_i_visit_the(:assessor_application_page, application_id:)
    and_i_click_professional_standing_task
    then_i_see_the(
      :assessor_professional_standing_request_page,
      application_id:,
      assessment_id:,
    )
    and_the_request_lops_verification_status_is("NOT STARTED")
    and_i_click_request_lops_verification
    then_i_see_the(
      :assessor_professional_standing_request_edit_page,
      application_id:,
      assessment_id:,
    )
    then_i_select_no
    and_i_submit
    then_i_see_the(
      :assessor_professional_standing_request_page,
      application_id:,
      assessment_id:,
    )
    and_i_click_request_lops_verification
    then_i_select_yes
    and_i_submit
    then_i_see_the(
      :assessor_professional_standing_request_page,
      application_id:,
      assessment_id:,
    )
    and_the_request_lops_verification_status_is("COMPLETED")
  end

  private

  def given_there_is_an_application_form_with_professional_standing_request
    application_form
  end

  def and_i_click_professional_standing_task
    assessor_application_page.professional_standing_request_task.link.click
  end

  def and_the_request_lops_verification_status_is(status)
    expect(
      :assessor_professional_standing_request_page
        .request_lops_verification_task
        .status_tag
        .text,
    ).to eq(status)
  end

  def and_i_click_request_lops_verification
    :assessor_professional_standing_request_page
      .request_lops_verification_task
      .link
      .click
  end

  def then_i_select_no
    :assessor_professional_standing_request_edit_page.form.no_radio_item.choose
  end

  def then_i_select_yes
    :assessor_professional_standing_request_edit_page.form.yes_radio_item.choose
  end

  def and_i_submit
    :assessor_professional_standing_request_edit_page.form.continue_button.click
  end

  def application_form
    @application_form ||=
      begin
        application_form =
          create(
            :application_form,
            :waiting_on,
            waiting_on_professional_standing: true,
            statuses: %w[waiting_on_lops],
          )
        create(
          :assessment,
          :with_received_professional_standing_request,
          application_form:,
        )
        application_form
      end
  end

  def application_id
    application_form.id
  end

  def assessment_id
    application_form.assessment.id
  end
end
