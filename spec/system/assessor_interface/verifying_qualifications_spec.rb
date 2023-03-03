# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor verifying qualifications", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_qualification_request
  end

  it "record location and review" do
    when_i_visit_the(:assessor_application_page, application_id:)
    and_i_see_a_waiting_on_status
    and_i_click_record_qualifications_task
    then_i_see_the(
      :assessor_qualification_request_locations_page,
      application_id:,
    )

    when_i_select_the_first_qualification_request
    then_i_see_the(
      :assessor_edit_qualification_request_location_page,
      application_id:,
    )

    when_i_fill_in_the_location_form
    then_i_see_the(
      :assessor_qualification_request_locations_page,
      application_id:,
    )

    when_i_click_continue_from_locations
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_a_received_status

    when_i_click_review_qualifications_task
    then_i_see_the(
      :assessor_qualification_request_reviews_page,
      application_id:,
    )

    when_i_select_the_first_qualification_request
    then_i_see_the(
      :assessor_edit_qualification_request_review_page,
      application_id:,
    )

    when_i_fill_in_the_review_form
    then_i_see_the(
      :assessor_qualification_request_reviews_page,
      application_id:,
    )

    when_i_click_continue_from_reviews
    and_i_see_a_received_status
  end

  private

  def given_there_is_an_application_form_with_qualification_request
    application_form
  end

  def and_i_see_a_waiting_on_status
    expect(assessor_application_page.overview.status.text).to eq("WAITING ON")
  end

  def and_i_click_record_qualifications_task
    assessor_application_page.record_qualification_requests_task.link.click
  end

  def when_i_click_review_qualifications_task
    assessor_application_page.review_qualification_requests_task.link.click
  end

  def when_i_select_the_first_qualification_request
    assessor_qualification_request_locations_page
      .task_list
      .qualification_requests
      .first
      .click
  end

  def when_i_fill_in_the_location_form
    form = assessor_edit_qualification_request_location_page.form

    form.received_checkbox.click
    form.note_textarea.fill_in with: "Note."
    form.submit_button.click
  end

  def when_i_fill_in_the_review_form
    form = assessor_edit_qualification_request_review_page.form

    form.reviewed_yes_radio_item.choose
    form.passed_yes_radio_item.choose
    form.submit_button.click
  end

  def when_i_click_continue_from_locations
    assessor_qualification_request_locations_page.continue_button.click
  end

  def when_i_click_continue_from_reviews
    assessor_qualification_request_reviews_page.continue_button.click
  end

  def and_i_see_a_received_status
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
