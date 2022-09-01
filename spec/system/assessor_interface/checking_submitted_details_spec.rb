require "rails_helper"

RSpec.describe "Assessor check submitted details", type: :system do
  before do
    given_the_service_is_open
    given_an_assessor_exists
    given_there_is_an_application_form
    given_i_am_authorized_as_an_assessor_user(assessor)
  end

  it "allows checking the qualifications" do
    when_i_visit_the_check_qualifications_page
    then_i_see_the_qualifications

    when_i_click_continue
    then_i_see_the_application_page
  end

  it "allows checking the work history" do
    when_i_visit_the_check_work_history_page
    then_i_see_the_work_history

    when_i_click_continue
    then_i_see_the_application_page
  end

  it "allows checking the professional standing" do
    when_i_visit_the_check_professional_standing_page
    then_i_see_the_professional_standing

    when_i_click_continue
    then_i_see_the_application_page
  end

  private

  def given_an_assessor_exists
    assessor
  end

  def given_there_is_an_application_form
    application_form
  end

  def when_i_visit_the_check_qualifications_page
    check_qualifications_page.load(application_id: application_form.id)
  end

  def when_i_visit_the_check_work_history_page
    check_work_history_page.load(application_id: application_form.id)
  end

  def when_i_visit_the_check_professional_standing_page
    check_professional_standing_page.load(application_id: application_form.id)
  end

  def then_i_see_the_qualifications
    expect(check_qualifications_page.heading).to have_content(
      "Check qualifications"
    )
    expect(
      check_qualifications_page.qualification_cards.first.heading
    ).to have_content("Your teaching qualification")
  end

  def then_i_see_the_work_history
    expect(check_work_history_page.heading).to have_content(
      "Check work history"
    )
    expect(
      check_work_history_page.work_history_cards.first.heading
    ).to have_content("Add your work history")
    expect(
      check_work_history_page.work_history_cards.second.heading
    ).to have_content("Your current or most recent role")
  end

  def then_i_see_the_professional_standing
    expect(check_professional_standing_page.heading).to have_content(
      "Check professional standing"
    )
    expect(
      check_professional_standing_page.professional_standing_cards.first.heading
    ).to have_content("Enter your registration number")
  end

  def when_i_click_continue
    check_qualifications_page.continue_button.click
  end

  def then_i_see_the_application_page
    expect(page).to have_content("Overview")
  end

  def assessor
    @assessor ||= create(:staff, :confirmed)
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :submitted,
        :with_completed_qualification,
        :with_work_history,
        :with_registration_number
      )
  end

  def check_qualifications_page
    @check_qualifications_page ||=
      PageObjects::AssessorInterface::CheckQualifications.new
  end

  def check_work_history_page
    @check_work_history_page ||=
      PageObjects::AssessorInterface::CheckWorkHistory.new
  end

  def check_professional_standing_page
    @check_professional_standing_page ||=
      PageObjects::AssessorInterface::CheckProfessionalStanding.new
  end
end
