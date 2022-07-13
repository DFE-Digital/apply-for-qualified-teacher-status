# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Eligibility check", type: :system do
  before do
    given_countries_exist
    given_the_service_is_open
    given_the_service_can_be_started
  end

  it "happy path" do
    when_i_visit_the_start_page
    then_i_see_the_start_page

    when_i_press_start_now
    then_i_see_the_countries_page

    when_i_select_a_country
    and_i_submit
    then_i_see_the_qualifications_page

    when_i_choose_yes
    and_i_submit
    then_i_see_the_degree_page

    when_i_choose_yes
    and_i_submit
    then_i_see_the_teach_children_page

    when_i_choose_yes
    and_i_submit
    then_i_see_the_misconduct_page

    when_i_choose_no
    and_i_submit
    then_i_see_the_eligible_page

    when_i_visit_the_start_page
    then_i_see_the_start_page
    when_i_press_start_now
    then_i_have_two_eligibility_checks
  end

  it "ineligible paths" do
    when_i_visit_the_start_page

    when_i_press_start_now
    when_i_select_an_ineligible_country
    and_i_submit
    then_i_see_the_ineligible_page
    and_i_see_the_ineligible_country_text

    when_i_press_back
    when_i_select_a_country
    and_i_submit
    then_i_see_the_qualifications_page

    when_i_choose_no
    and_i_submit
    then_i_see_the_degree_page

    when_i_choose_no
    and_i_submit
    then_i_see_the_teach_children_page

    when_i_choose_no
    and_i_submit
    then_i_see_the_misconduct_page

    when_i_choose_yes
    and_i_submit
    then_i_see_the_ineligible_page
    and_i_see_the_ineligible_degree_text
    and_i_see_the_ineligible_qualification_text
    and_i_see_the_ineligible_teach_children_text
    and_i_see_the_ineligible_misconduct_text
  end

  it "trying to skip steps" do
    when_i_visit_the_start_page
    then_i_see_the_start_page

    when_i_try_to_go_to_the_eligible_page
    then_i_see_the_start_page

    when_i_try_to_go_to_the_ineligible_page
    then_i_see_the_start_page

    when_i_press_start_now
    then_i_see_the_countries_page

    when_i_try_to_go_to_the_region_page
    then_i_see_the_countries_page

    when_i_select_a_country
    and_i_submit
    then_i_see_the_qualifications_page

    when_i_try_to_go_to_the_degree_page
    then_i_see_the_qualifications_page

    when_i_choose_yes
    and_i_submit
    then_i_see_the_degree_page

    when_i_try_to_go_to_the_teach_children_page
    then_i_see_the_degree_page

    when_i_choose_yes
    and_i_submit
    then_i_see_the_teach_children_page

    when_i_try_to_go_to_the_misconduct_page
    then_i_see_the_teach_children_page

    when_i_choose_yes
    and_i_submit
    then_i_see_the_misconduct_page
  end

  it "handles the country picker error" do
    when_i_visit_the_start_page
    when_i_press_start_now
    and_i_submit
    then_i_see_the_country_error_message

    when_i_select_a_country_in_the_error_state
    and_i_submit
    then_i_see_the_qualifications_page
  end

  it "sends legacy users to the old service" do
    when_i_visit_the_start_page
    when_i_press_start_now
    when_i_select_a_legacy_country
    and_i_submit
    then_i_see_the_eligible_page

    when_i_press_start
    then_i_see_the_legacy_service
  end

  it "handles countries with multiple regions" do
    when_i_visit_the_start_page
    when_i_press_start_now
    when_i_select_a_country_with_multiple_regions
    and_i_submit
    then_i_see_the_region_page

    when_i_choose_region
    and_i_submit
    then_i_see_the_qualifications_page
  end

  it "service is closed" do
    given_the_service_is_closed
    when_i_visit_the_start_page
    then_i_do_not_see_the_start_page

    when_i_am_authorized_as_a_support_user
    when_i_visit_the_start_page
    then_i_see_the_start_page

    given_the_service_is_open
    when_i_visit_the_start_page
    then_i_see_the_start_page
  end

  it "service cannot be started" do
    given_the_service_cannot_be_started
    when_i_visit_the_start_page
    then_i_do_not_see_the_start_page
    then_i_see_the_legacy_service
  end

  private

  def and_i_submit
    click_button "Continue", visible: false
  end

  def given_countries_exist
    create(:country, :with_national_region, code: "GB-SCT")
    create(:country, :with_legacy_region, code: "FR")

    it = create(:country, code: "IT")
    create(:region, country: it, name: "Region")
    create(:region, country: it, name: "Other Region")
  end

  def given_the_service_cannot_be_started
    FeatureFlag.deactivate(:service_start)
  end

  def given_the_service_can_be_started
    FeatureFlag.activate(:service_start)
  end

  def when_i_choose_no
    choose "No", visible: false
  end

  def when_i_choose_yes
    choose "Yes", visible: false
  end

  def when_i_choose_region
    choose "Region", visible: false
  end

  def when_i_press_back
    click_link "Back"
  end

  def when_i_press_start_now
    click_button "Start now"
  end

  def when_i_press_start
    click_link "Apply for QTS"
  end

  def when_i_select_a_country
    fill_in "eligibility-interface-country-form-location-field",
            with: "Scotland"
  end

  def when_i_select_a_country_in_the_error_state
    fill_in "eligibility-interface-country-form-location-field-error",
            with: "Scotland"
  end

  def when_i_select_an_ineligible_country
    fill_in "eligibility-interface-country-form-location-field", with: "Spain"
  end

  def when_i_select_a_legacy_country
    fill_in "eligibility-interface-country-form-location-field", with: "France"
  end

  def when_i_select_a_country_with_multiple_regions
    fill_in "eligibility-interface-country-form-location-field", with: "Italy"
  end

  def when_i_visit_the_start_page
    visit "/eligibility"
  end

  def when_i_try_to_go_to_the_eligible_page
    visit "/eligibility/eligible"
  end

  def when_i_try_to_go_to_the_ineligible_page
    visit "/eligibility/ineligible"
  end

  def when_i_try_to_go_to_the_region_page
    visit "/eligibility/region"
  end

  def when_i_try_to_go_to_the_degree_page
    visit "/eligibility/degree"
  end

  def when_i_try_to_go_to_the_qualifications_page
    visit "/eligibility/qualifications"
  end

  def when_i_try_to_go_to_the_teach_children_page
    visit "/eligibility/teach-children"
  end

  def when_i_try_to_go_to_the_misconduct_page
    visit "/eligibility/misconduct"
  end

  def then_i_do_not_see_the_start_page
    expect(page).not_to have_content(
      "Check your eligilibity to apply for qualified teacher status (QTS) in England"
    )
  end

  def then_i_see_the_start_page
    expect(page).to have_content(
      "Check your eligilibity to apply for qualified teacher status (QTS) in England"
    )
    expect(page).to have_current_path("/eligibility/start")
    expect(page).to have_title(
      "Check your eligilibity to apply for qualified teacher status (QTS) in England"
    )
  end

  def then_i_see_the_misconduct_page
    expect(page).to have_current_path("/eligibility/misconduct")
    expect(page).to have_content(
      "Do you have any sanctions or restrictions on your employment record?"
    )
  end

  def then_i_see_the_countries_page
    expect(page).to have_current_path("/eligibility/countries")
    expect(page).to have_title(
      "In which country are you currently recognised as a teacher?"
    )
    expect(page).to have_content(
      "In which country are you currently recognised as a teacher?"
    )
  end

  def then_i_see_the_region_page
    expect(page).to have_current_path("/eligibility/region")
    expect(page).to have_title(
      "In which state/territory are you currently recognised as a teacher?"
    )
    expect(page).to have_content(
      "In which state/territory are you currently recognised as a teacher?"
    )
  end

  def then_i_see_the_country_error_message
    expect(page).to have_content(
      "Tell us where you’re currently recognised as a teacher"
    )
  end

  def then_i_see_the_eligible_page
    expect(page).to have_current_path("/eligibility/eligible")
    expect(page).to have_content(
      "You’re eligible to apply for qualified teacher status (QTS) in England"
    )
  end

  def then_i_see_the_ineligible_page
    expect(page).to have_current_path("/eligibility/ineligible")
    expect(page).to have_content(
      "You’re not eligible to apply for qualified teacher status (QTS) in England"
    )
  end

  def then_i_see_the_legacy_service
    expect(page).to have_current_path("/MutualRecognition/")
  end

  def and_i_see_the_ineligible_country_text
    expect(page).to have_content(
      "You’re not eligible to apply for qualified teacher status (QTS) in England"
    )
    expect(page).to have_content(
      "Teachers applying from Spain are not currently eligible to use this service."
    )
    expect(page).to have_content(
      "You can also learn more about teaching in England."
    )
  end

  def and_i_see_the_ineligible_completed_requirements_text
    expect(page).to have_content(
      "You have not completed all requirements to work as a qualified teacher in Scotland."
    )
  end

  def and_i_see_the_ineligible_misconduct_text
    expect(page).to have_content(
      "To teach in England, you must not have any findings of misconduct or restrictions on your practice."
    )
  end

  def and_i_see_the_ineligible_teach_children_text
    expect(page).to have_content(
      "You are not qualified to teach children who are aged somewhere between 5 and 16 years."
    )
  end

  def and_i_see_the_ineligible_qualification_text
    expect(page).to have_content(
      "You have not completed a formal teacher training course, for example, an undergraduate teaching " \
        "degree or postgraduate teacher training course."
    )
  end

  def and_i_see_the_ineligible_degree_text
    expect(page).to have_content("You do not have a degree.")
  end

  def then_i_see_the_completed_requirements_page
    expect(page).to have_current_path("/eligibility/completed-requirements")
    expect(page).to have_title(
      "Have you completed all requirements to work as a qualified teacher in"
    )
    expect(page).to have_content(
      "Have you completed all requirements to work as a qualified teacher in"
    )
  end

  def then_i_see_the_degree_page
    expect(page).to have_current_path("/eligibility/degree")
    expect(page).to have_title("Do you have a university degree?")
    expect(page).to have_content("Do you have a university degree?")
  end

  def then_i_see_the_qualifications_page
    expect(page).to have_current_path("/eligibility/qualifications")
    expect(page).to have_title("Do you have a teacher training qualification?")
    expect(page).to have_content(
      "Do you have a teacher training qualification?"
    )
  end

  def then_i_see_the_start_page
    expect(page).to have_content("Apply for qualified teacher status")
    expect(page).to have_content(
      "This service is for qualified teachers who trained outside of England" \
        " who want to apply for qualified teacher status (QTS) to teach in" \
        " English schools."
    )
  end

  def then_i_see_the_teach_children_page
    expect(page).to have_current_path("/eligibility/teach-children")
    expect(page).to have_title(
      "Are you qualified to teach children who are aged somewhere between 5 and 16 years?"
    )
    expect(page).to have_content(
      "Are you qualified to teach children who are aged somewhere between 5 and 16 years?"
    )
  end

  def then_i_have_two_eligibility_checks
    expect(EligibilityCheck.count).to eq(2)
  end
end
