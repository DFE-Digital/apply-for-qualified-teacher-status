# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor verifying professional standing", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_professional_standing_request
  end

  it "record location and review" do
    when_i_visit_the(:assessor_application_page, application_id:)
    and_i_see_a_waiting_on_status
    and_i_click_record_professional_standing_task
    then_i_see_the(
      :assessor_edit_professional_standing_request_location_page,
      application_id:,
    )

    when_i_fill_in_the_location_form
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_a_received_status

    when_i_click_review_professional_standing_task
    then_i_see_the(
      :assessor_edit_professional_standing_request_review_page,
      application_id:,
    )

    when_i_fill_in_the_review_form
    then_i_see_the(:assessor_application_page, application_id:)
  end

  private

  def given_there_is_an_application_form_with_professional_standing_request
    application_form
  end

  def and_i_see_a_waiting_on_status
    expect(assessor_application_page.overview.status.text).to eq("WAITING ON")
  end

  def and_i_click_record_professional_standing_task
    assessor_application_page
      .record_professional_standing_request_task
      .link
      .click
  end

  def when_i_click_review_professional_standing_task
    assessor_application_page
      .review_professional_standing_request_task
      .link
      .click
  end

  def when_i_fill_in_the_location_form
    form = assessor_edit_professional_standing_request_location_page.form

    form.received_checkbox.click
    form.note_textarea.fill_in with: "Note."
    form.submit_button.click
  end

  def when_i_fill_in_the_review_form
    form = assessor_edit_professional_standing_request_review_page.form

    form.yes_radio_item.choose
    form.submit_button.click
  end

  def and_i_see_a_received_status
    expect(assessor_application_page.overview.status.text).to eq("RECEIVED")
  end

  def application_form
    @application_form ||=
      begin
        application_form = create(:application_form, :waiting_on)
        create(
          :assessment,
          :with_professional_standing_request,
          application_form:,
        )
        application_form
      end
  end

  def application_id
    application_form.id
  end
end
