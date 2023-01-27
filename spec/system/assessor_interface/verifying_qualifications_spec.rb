# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor verifying qualifications", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_qualification_request
  end

  it "review complete" do
    when_i_visit_the(:assessor_application_page, application_id:)
    and_i_see_a_waiting_on_status
    and_i_click_qualification_requested
    then_i_see_the(:assessor_edit_qualification_request_page, application_id:)

    when_i_fill_in_the_form
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_a_not_started_status
  end

  private

  def given_there_is_an_application_form_with_qualification_request
    application_form
  end

  def and_i_see_a_waiting_on_status
    expect(assessor_application_page.overview.status.text).to eq("WAITING ON")
  end

  def and_i_click_qualification_requested
    assessor_application_page.requested_qualifications_task.link.click
  end

  def when_i_fill_in_the_form
    assessor_edit_qualification_request_page.form.received_checkbox.click
    assessor_edit_qualification_request_page.form.note_textarea.fill_in with:
      "Note."
    assessor_edit_qualification_request_page.form.continue_button.click
  end

  def and_i_see_a_not_started_status
    expect(assessor_application_page.overview.status.text).to eq("RECEIVED")
  end

  def application_form
    @application_form ||=
      begin
        application_form =
          create(:application_form, :waiting_on, :with_completed_qualification)
        create(:assessment, :with_qualification_request, application_form:)
        application_form
      end
  end

  def application_id
    application_form.id
  end
end
