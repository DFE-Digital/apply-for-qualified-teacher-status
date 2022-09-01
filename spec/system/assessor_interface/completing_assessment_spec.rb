# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor completing assessment", type: :system do
  it "completes an assessment" do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user(assessor)
    given_there_is_an_application_form

    when_i_visit_the_complete_assessment_page
    and_i_select_award
    then_the_application_form_is_awarded
  end

  private

  def given_there_is_an_application_form
    application_form
  end

  def when_i_visit_the_complete_assessment_page
    visit assessor_interface_application_form_complete_assessment_path(
            application_form
          )
  end

  def and_i_select_award
    choose "Award QTS", visible: false
    click_button "Continue"
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
end
