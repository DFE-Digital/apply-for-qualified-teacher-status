# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor awaiting professional standing", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_professional_standing_request
  end

  it "review complete" do
    when_i_visit_the(:assessor_application_page, application_id:)
    and_i_see_a_waiting_on_status
    and_i_click_awaiting_professional_standing
    then_i_see_the(
      :assessor_edit_professional_standing_request_location_page,
      application_id:,
    )

    when_i_fill_in_the_form
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_a_not_started_status
    and_the_teacher_receives_a_professional_standing_received_email
  end

  private

  def given_there_is_an_application_form_with_professional_standing_request
    application_form
  end

  def and_i_see_a_waiting_on_status
    expect(assessor_application_page.status_summary.value).to have_text(
      "WAITING ON LOPS",
    )
  end

  def and_i_click_awaiting_professional_standing
    assessor_application_page.awaiting_professional_standing_task.link.click
  end

  def when_i_fill_in_the_form
    form = assessor_edit_professional_standing_request_location_page.form

    form.received_checkbox.click
    form.note_textarea.fill_in with: "Note."
    form.submit_button.click
  end

  def and_i_see_a_not_started_status
    expect(assessor_application_page.status_summary.value).to have_text(
      "NOT STARTED",
    )
  end

  def and_the_teacher_receives_a_professional_standing_received_email
    message = ActionMailer::Base.deliveries.last
    expect(message).to_not be_nil

    expect(message.subject).to eq(
      "Your qualified teacher status application – we’ve received " \
        "your letter that proves you’re recognised as a teacher",
    )
    expect(message.to).to include(application_form.teacher.email)
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :waiting_on,
        waiting_on_professional_standing: true,
        statuses: %w[waiting_on_lops],
        assessment: create(:assessment, :with_professional_standing_request),
        teaching_authority_provides_written_statement: true,
      )
  end

  def application_id
    application_form.id
  end
end
