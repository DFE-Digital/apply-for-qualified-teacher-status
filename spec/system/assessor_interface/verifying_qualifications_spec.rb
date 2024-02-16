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

    when_i_go_back_to_overview
    then_i_see_the(:assessor_application_page, reference:)
  end

  private

  def given_there_is_an_application_form_with_qualification_request
    application_form
  end

  def and_i_click_the_verify_qualifications_task
    assessor_application_page.verify_qualifications_task.link.click
  end

  def when_i_go_back_to_overview
    assessor_qualification_requests_page.continue_button.click
  end

  def and_i_see_a_received_status
    expect(assessor_application_page.status_summary.value).to have_text(
      "RECEIVED",
    )
  end

  def and_i_see_an_in_progress_status
    expect(assessor_application_page.status_summary.value).to have_text(
      "VERIFICATION IN PROGRESS",
    )
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :submitted,
        :verification_stage,
        :with_teaching_qualification,
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
