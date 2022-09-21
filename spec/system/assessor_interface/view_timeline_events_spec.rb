require "rails_helper"

RSpec.describe "Assessor view timeline events", type: :system do
  before do
    given_the_service_is_open
    given_an_assessor_exists
    given_an_application_form_exists
    given_i_am_authorized_as_an_assessor_user(assessor)
  end

  it "displays the timeline events" do
    when_i_visit_the(:assessor_application_page, application_id:)
    and_i_click_view_timeline
    then_i_see_the_timeline
  end

  private

  def given_an_assessor_exists
    assessor
  end

  def given_an_application_form_exists
    application_form
  end

  def and_i_click_view_timeline
    assessor_application_page.overview.click_link(
      "View timeline of this applications actions",
    )
  end

  def then_i_see_the_timeline
    expect(timeline_page).to have_heading
    expect(timeline_page.heading).to have_content("Application history")

    expect(timeline_page).to have_timeline_items
    expect(timeline_page.timeline_items.first.title).to have_content(
      "Status changed",
    )
    expect(timeline_page.timeline_items.second.title).to have_content(
      "Assessor assigned",
    )
  end

  def application_form
    @application_form ||=
      begin
        application_form =
          create(:application_form, :submitted, :with_assessment)
        create(:timeline_event, :assessor_assigned, application_form:)
        create(:timeline_event, :state_changed, application_form:)
        application_form
      end
  end

  def application_id
    application_form.id
  end

  def assessor
    @assessor ||= create(:staff, :confirmed)
  end
end
