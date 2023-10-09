# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor verifying professional standing", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_an_admin_user
    given_there_is_an_application_form_with_professional_standing_request
  end

  it "verify" do
    when_i_visit_the(:assessor_application_page, application_form_id:)
    and_i_click_professional_standing_task
    then_i_see_the(
      :assessor_professional_standing_request_page,
      application_form_id:,
      assessment_id:,
    )
    and_the_request_lops_verification_status_is("NOT STARTED")

    when_i_click_request_lops_verification
    then_i_see_the(
      :assessor_request_professional_standing_request_page,
      application_form_id:,
      assessment_id:,
    )
    then_i_select_no
    and_i_submit
    then_i_see_the(
      :assessor_professional_standing_request_page,
      application_form_id:,
      assessment_id:,
    )

    when_i_click_request_lops_verification
    then_i_select_yes
    and_i_submit
    then_i_see_the(
      :assessor_professional_standing_request_page,
      application_form_id:,
      assessment_id:,
    )
    and_the_request_lops_verification_status_is("COMPLETED")

    # when_i_click_record_lops_verification
    # then_i_see_the(
    #   :assessor_verify_professional_standing_request_page,
    #   application_form_id:,
    #   assessment_id:,
    # )
    # and_i_fill_in_the_verify_form
    # then_i_see_the(
    #   :assessor_professional_standing_request_page,
    #   application_form_id:,
    #   assessment_id:,
    # )
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

  def when_i_click_record_lops_verification
    assessor_professional_standing_request_page.record_lops_verification_task.click
  end

  def and_the_request_lops_verification_status_is(status)
    expect(
      assessor_professional_standing_request_page
        .request_lops_verification_task
        .status_tag
        .text,
    ).to eq(status)
  end

  def and_i_fill_in_the_verify_form
    form = assessor_verify_professional_standing_request_page.form

    form.yes_radio_item.choose
    form.submit_button.click
  end

  def then_i_select_no
    assessor_request_professional_standing_request_page
      .form
      .no_radio_item
      .choose
  end

  def then_i_select_yes
    assessor_request_professional_standing_request_page
      .form
      .yes_radio_item
      .choose
  end

  def and_i_submit
    assessor_request_professional_standing_request_page
      .form
      .continue_button
      .click
  end

  def application_form
    @application_form ||=
      begin
        application_form = create(:application_form, :submitted)
        create(
          :assessment,
          :with_professional_standing_request,
          application_form:,
        )
        application_form
      end
  end

  delegate :id, to: :application_form, prefix: true

  def assessment_id
    application_form.assessment.id
  end
end
