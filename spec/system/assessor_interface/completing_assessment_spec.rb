# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor completing assessment", type: :system do
  it "completes an assessment" do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user(assessor)
    given_there_is_an_application_form

    when_i_visit_the_complete_assessment_page
    then_i_see_the_complete_assessment_form

    when_i_select_award_qts
    and_i_click_continue
    then_the_application_form_is_awarded
  end

  private

  def given_there_is_an_application_form
    application_form
  end

  def when_i_visit_the_complete_assessment_page
    complete_assessment_page.load(application_id: application_form.id)
  end

  def then_i_see_the_complete_assessment_form
    expect(complete_assessment_page.heading).to have_content(
      "QTS review completed"
    )
    expect(complete_assessment_page.new_states.first).to have_content(
      "Award QTS"
    )
    expect(complete_assessment_page.new_states.second).to have_content(
      "Decline QTS"
    )
  end

  def when_i_select_award_qts
    complete_assessment_page.new_states.first.input.choose
  end

  def then_the_application_form_is_awarded
    expect(page).to have_content("Status\tAWARDED")
  end

  def application_form
    @application_form ||=
      create(:application_form, :with_personal_information, :submitted)
  end

  def assessor
    @assessor ||= create(:staff, :confirmed)
  end

  def complete_assessment_page
    @complete_assessment_page ||=
      PageObjects::AssessorInterface::CompleteAssessment.new
  end
end
