# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor verifying qualifications", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_an_admin_user
    given_there_is_an_application_form_with_qualification_request
  end

  it "check and select consent method" do
    when_i_visit_the(:assessor_application_page, reference:)
    and_i_click_the_verify_qualifications_task
    then_i_see_the(:assessor_qualification_requests_page, reference:)
    and_the_check_and_select_consent_method_task_is_not_started

    when_i_click_the_check_and_select_consent_method_task
    then_i_see_the(:assessor_qualification_requests_consent_methods_page)

    when_i_click_the_continue_button
    then_i_see_the(:assessor_consent_qualification_request_page)

    when_i_choose_the_unsigned_consent_method
    then_i_see_the(:assessor_consent_qualification_request_page)

    when_i_choose_a_signed_consent_method
    then_i_see_the(:assessor_qualification_requests_check_consent_methods_page)

    when_i_confirm_the_consent_methods
    then_i_see_the(:assessor_qualification_requests_page, reference:)
    and_the_check_and_select_consent_method_task_is_completed
    and_i_go_back_to_overview
    then_i_see_the(:assessor_application_page, reference:)
  end

  private

  def given_there_is_an_application_form_with_qualification_request
    application_form
  end

  def and_i_click_the_verify_qualifications_task
    assessor_application_page.verify_qualifications_task.link.click
  end

  def and_the_check_and_select_consent_method_task_is_not_started
    expect(check_and_select_consent_method_task_item.status_tag.text).to eq(
      "NOT STARTED",
    )
  end

  def when_i_click_the_check_and_select_consent_method_task
    check_and_select_consent_method_task_item.click
  end

  def when_i_click_the_continue_button
    assessor_qualification_requests_consent_methods_page.continue_button.click
  end

  def when_i_choose_the_unsigned_consent_method
    assessor_consent_qualification_request_page.submit_unsigned
  end

  def when_i_choose_a_signed_consent_method
    assessor_consent_qualification_request_page.submit_signed_ecctis
  end

  def when_i_confirm_the_consent_methods
    assessor_qualification_requests_check_consent_methods_page.continue_button.click
  end

  def and_the_check_and_select_consent_method_task_is_completed
    expect(check_and_select_consent_method_task_item.status_tag.text).to eq(
      "COMPLETED",
    )
  end

  def and_i_go_back_to_overview
    assessor_qualification_requests_page.continue_button.click
  end

  def and_i_see_a_received_status
    expect(assessor_application_page.status_summary.value).to have_text(
      "RECEIVED",
    )
  end

  def check_and_select_consent_method_task_item
    assessor_qualification_requests_page.task_lists.first.find_item(
      "Check and select consent method",
    )
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :submitted,
        :verification_stage,
        :with_degree_qualification,
      ).tap do |application_form|
        create(
          :assessment,
          :started,
          :with_qualification_requests,
          application_form:,
        )
      end
  end

  delegate :reference, to: :application_form
end
