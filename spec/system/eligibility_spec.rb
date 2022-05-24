# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Eligibility check", type: :system do
  before { given_the_service_is_open }

  it "happy path" do
    when_i_visit_the_start_page
    then_i_see_the_start_page

    when_i_press_continue
    then_i_see_the_countries_page

    when_i_select_a_country
    and_i_submit
    then_i_see_the_degree_page

    when_i_choose_yes
    and_i_submit
    then_i_see_the_qualification_page

    when_i_choose_yes
    and_i_submit
    then_i_see_the_teach_children_page

    when_i_choose_yes
    and_i_submit
    then_i_see_the_recognised_page

    when_i_choose_yes
    and_i_submit
    then_i_see_the_clean_record_page

    when_i_choose_yes
    and_i_submit
    then_i_see_the_eligible_page
  end

  it "ineligible paths" do
    when_i_visit_the_start_page
    when_i_press_continue
    when_i_select_a_country
    and_i_submit
    when_i_choose_no
    and_i_submit
    then_i_see_the_ineligible_page
    and_i_see_the_ineligible_degree_text

    when_i_press_back
    when_i_choose_yes
    and_i_submit
    when_i_choose_no
    and_i_submit
    then_i_see_the_ineligible_page
    and_i_see_the_ineligible_qualification_text

    when_i_press_back
    when_i_choose_yes
    and_i_submit
    when_i_choose_no
    and_i_submit
    then_i_see_the_ineligible_page
    and_i_see_the_ineligible_teach_children_text

    when_i_press_back
    when_i_choose_yes
    and_i_submit
    when_i_choose_no
    and_i_submit
    then_i_see_the_ineligible_page
    and_i_see_the_ineligible_recognised_text

    when_i_press_back
    when_i_choose_yes
    and_i_submit
    when_i_choose_no
    and_i_submit
    then_i_see_the_ineligible_page
    and_i_see_the_ineligible_misconduct_text
  end

  it "handles the country picker error" do
    when_i_visit_the_start_page
    when_i_press_continue
    and_i_submit
    then_i_see_the_country_error_message

    when_i_select_a_country_in_the_error_state
    and_i_submit
    then_i_see_the_degree_page
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

  private

  def and_i_submit
    click_button "Continue", visible: false
  end

  def given_the_service_is_closed
    FeatureFlag.deactivate(:service_open)
  end

  def given_the_service_is_open
    FeatureFlag.activate(:service_open)
  end

  def when_i_am_authorized_as_a_support_user
    page.driver.basic_authorize("test", "test")
  end

  def when_i_choose_no
    choose "No", visible: false
  end

  def when_i_choose_yes
    choose "Yes", visible: false
  end

  def when_i_press_back
    click_link "Back"
  end

  def when_i_press_continue
    click_link "Continue"
  end

  def when_i_select_a_country
    fill_in "country-form-country-code-field", with: "United Kingdom"
  end

  def when_i_select_a_country_in_the_error_state
    fill_in "country-form-country-code-field-error", with: "United Kingdom"
  end

  def when_i_select_an_ineligible_country
    select "Other", from: "country-form-country-code-field"
  end

  def when_i_visit_the_start_page
    visit "/teacher"
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
    expect(page).to have_current_path("/teacher/start")
    expect(page).to have_title(
      "Check your eligilibity to apply for qualified teacher status (QTS) in England"
    )
  end

  def then_i_see_the_clean_record_page
    expect(page).to have_current_path("/teacher/misconduct")
    expect(page).to have_content(
      "Is your employment record as a teacher free of sanctions?"
    )
  end

  def then_i_see_the_countries_page
    expect(page).to have_current_path("/teacher/countries")
    expect(page).to have_title(
      "Where are you currently recognised as a teacher?"
    )
    expect(page).to have_content(
      "Where are you currently recognised as a teacher?"
    )
  end

  def then_i_see_the_country_error_message
    expect(page).to have_content(
      "Tell us where you are currently recognised as a teacher"
    )
  end

  def then_i_see_the_eligible_page
    expect(page).to have_current_path("/teacher/eligible")
    expect(page).to have_content("You might be eligible to apply for QTS")
  end

  def then_i_see_the_ineligible_page
    expect(page).to have_current_path("/teacher/ineligible")
    expect(page).to have_content(
      "You’re not eligible to apply for qualified teacher status (QTS) in England"
    )
  end

  def and_i_see_the_ineligible_country_text
    expect(page).to have_content(
      "You’re not eligible to apply for qualified teacher status (QTS) in England"
    )
  end

  def and_i_see_the_ineligible_misconduct_text
    expect(page).to have_content(
      "To teach in England, you must not have any findings of misconduct or restrictions on your practice."
    )
  end

  def and_i_see_the_ineligible_recognised_text
    expect(page).to have_content(
      "This is because you are not recognised as a school teacher in the country where you trained."
    )
  end

  def and_i_see_the_ineligible_teach_children_text
    expect(page).to have_content(
      "You must have experience of teaching children who are aged somewhere between 5 and 16 years."
    )
  end

  def and_i_see_the_ineligible_qualification_text
    expect(page).to have_content(
      "This is because you have not completed a formal teacher training " \
        "course, for example, an undergraduate degree or postgraduate " \
        "teacher training course."
    )
  end

  def and_i_see_the_ineligible_degree_text
    expect(page).to have_content("This is because you do not have a degree.")
  end

  def then_i_see_the_degree_page
    expect(page).to have_current_path("/teacher/degree")
    expect(page).to have_title("Do you have a degree?")
    expect(page).to have_content("Do you have a degree?")
  end

  def then_i_see_the_qualification_page
    expect(page).to have_current_path("/teacher/qualifications")
    expect(page).to have_title("Do you have a teacher training qualification?")
    expect(page).to have_content(
      "Do you have a teacher training qualification?"
    )
  end

  def then_i_see_the_recognised_page
    expect(page).to have_current_path("/teacher/recognised")
    expect(page).to have_title(
      "Are you recognised as a teacher in the country where you trained?"
    )
    expect(page).to have_content(
      "Are you recognised as a teacher in the country where you trained?"
    )
  end

  def then_i_see_the_start_page
    expect(page).to have_content("Apply for qualified teacher status")
    expect(page).to have_content(
      "Teacher training in England leads to qualified teacher status (QTS)." \
        " QTS is a legal requirement to teach in many English schools."
    )
  end

  def then_i_see_the_teach_children_page
    expect(page).to have_current_path("/teacher/teach-children")
    expect(page).to have_title(
      "Are you qualified to teach children who are aged somewhere between 5 and 16 years?"
    )
    expect(page).to have_content(
      "Are you qualified to teach children who are aged somewhere between 5 and 16 years?"
    )
  end
end
