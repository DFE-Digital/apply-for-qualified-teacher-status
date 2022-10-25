# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Creating a note", type: :system do
  it "creates a note" do
    given_the_service_is_open
    given_i_am_authorized_as_a_user(assessor)
    given_there_is_an_application_form
    given_an_assessor_exists

    when_i_visit_the(
      :assessor_application_page,
      application_id: application_form.id,
    )
    and_i_click_add_note
    then_i_see_the(:create_note_page, application_id: application_form.id)

    when_i_create_a_note
    then_i_see_the(
      :assessor_application_page,
      application_id: application_form.id,
    )

    when_i_visit_the(:timeline_page, application_id: application_form.id)
    then_i_see_the(:timeline_page, application_id: application_form.id)
    and_i_see_the_note_timeline_event
  end

  private

  def given_there_is_an_application_form
    application_form
  end

  def given_an_assessor_exists
    assessor
  end

  def and_i_click_add_note
    assessor_application_page.add_note_button.click
  end

  def when_i_create_a_note
    create_note_page.form.text_textarea.fill_in with: "A note."
    create_note_page.form.submit_button.click
  end

  def and_i_see_the_note_timeline_event
    timeline_item = timeline_page.timeline_items.first

    expect(timeline_item.title).to have_content("Note created")

    expect(timeline_item.description).to have_content("A note.")
  end

  def application_form
    @application_form ||=
      create(:application_form, :submitted, :with_assessment)
  end

  def assessor
    @assessor ||= create(:staff, :confirmed)
  end
end
