# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Eligibility check", type: :system do
  before { given_countries_exist }

  it "happy path" do
    when_i_visit_the(:eligibility_start_page)
    then_i_see_the(:eligibility_start_page)

    when_i_press_start_now
    then_i_see_the(:eligibility_country_page)

    when_i_select_an_eligible_country
    then_i_see_the(:eligibility_qualification_page)

    when_i_have_a_qualification
    then_i_see_the(:eligibility_degree_page)

    when_i_have_a_degree
    then_i_see_the(:eligibility_teach_children_page)

    when_i_can_teach_children
    then_i_see_the(:eligibility_work_experience_page)

    when_i_have_more_than_20_months_work_experience
    then_i_see_the(:eligibility_misconduct_page)

    when_i_dont_have_a_misconduct_record
    then_i_see_the(:eligibility_eligible_page)

    when_i_visit_the(:eligibility_start_page)
    then_i_see_the(:eligibility_start_page)
    when_i_press_start_now
    then_i_have_two_eligibility_checks
  end

  it "ineligible paths" do
    when_i_visit_the(:eligibility_start_page)

    when_i_press_start_now
    when_i_select_an_ineligible_country
    then_i_see_the(:eligibility_ineligible_page)
    and_i_see_the_ineligible_country_text

    when_i_press_back
    when_i_select_an_eligible_country
    then_i_see_the(:eligibility_qualification_page)

    when_i_dont_have_a_qualification
    then_i_see_the(:eligibility_degree_page)

    when_i_dont_have_a_degree
    then_i_see_the(:eligibility_teach_children_page)

    when_i_cant_teach_children
    then_i_see_the(:eligibility_work_experience_page)

    when_i_have_under_9_months_work_experience
    then_i_see_the(:eligibility_misconduct_page)

    when_i_have_a_misconduct_record
    then_i_see_the(:eligibility_ineligible_page)
    and_i_see_the_ineligible_degree_text
    and_i_see_the_ineligible_qualification_text_with_eligible_country
    and_i_see_the_ineligible_teach_children_text
    and_i_see_the_ineligible_work_experience_text
    and_i_see_the_ineligible_misconduct_text
  end

  it "ineligible countries" do
    when_i_visit_the(:eligibility_start_page)

    when_i_press_start_now
    when_i_select_england
    then_i_see_the(:eligibility_ineligible_page)
    and_i_see_the_ineligible_england_or_wales_text

    when_i_press_back
    when_i_select_wales
    then_i_see_the(:eligibility_ineligible_page)
    and_i_see_the_ineligible_england_or_wales_text

    when_i_press_back
    when_i_select_nigeria
    then_i_see_the(:eligibility_ineligible_page)
  end

  it "trying to skip steps" do
    when_i_visit_the(:eligibility_start_page)
    then_i_see_the(:eligibility_start_page)

    when_i_visit_the(:eligibility_eligible_page)
    then_i_see_the(:eligibility_country_page)

    when_i_visit_the(:eligibility_ineligible_page)
    then_i_see_the(:eligibility_country_page)

    when_i_press_start_now
    then_i_see_the(:eligibility_country_page)

    when_i_visit_the(:eligibility_region_page)
    then_i_see_the(:eligibility_country_page)

    when_i_select_an_eligible_country
    then_i_see_the(:eligibility_qualification_page)

    when_i_visit_the(:eligibility_degree_page)
    then_i_see_the(:eligibility_qualification_page)

    when_i_have_a_qualification
    then_i_see_the(:eligibility_degree_page)

    when_i_visit_the(:eligibility_teach_children_page)
    then_i_see_the(:eligibility_degree_page)

    when_i_have_a_degree
    then_i_see_the(:eligibility_teach_children_page)

    when_i_visit_the(:eligibility_work_experience_page)
    then_i_see_the(:eligibility_teach_children_page)

    when_i_can_teach_children
    then_i_see_the(:eligibility_work_experience_page)

    when_i_visit_the(:eligibility_misconduct_page)
    then_i_see_the(:eligibility_work_experience_page)

    when_i_have_more_than_20_months_work_experience
    then_i_see_the(:eligibility_misconduct_page)
  end

  it "handles the country picker error" do
    when_i_visit_the(:eligibility_start_page)
    when_i_press_start_now
    when_i_dont_select_a_country
    then_i_see_the_country_error_message

    when_i_select_an_eligible_country
    then_i_see_the(:eligibility_qualification_page)
  end

  it "can skip questions with qualification" do
    when_i_visit_the(:eligibility_start_page)
    when_i_press_start_now
    when_i_select_a_skip_questions_country
    then_i_see_the(:eligibility_qualification_page)

    when_i_have_a_qualification
    then_i_see_the(:eligibility_eligible_page)
  end

  it "can skip questions without qualification" do
    when_i_visit_the(:eligibility_start_page)
    when_i_press_start_now
    when_i_select_a_skip_questions_country
    then_i_see_the(:eligibility_qualification_page)

    when_i_dont_have_a_qualification
    then_i_see_the(:eligibility_degree_page)

    when_i_dont_have_a_degree
    then_i_see_the(:eligibility_teach_children_page)

    when_i_cant_teach_children
    then_i_see_the(:eligibility_work_experience_page)

    when_i_have_under_9_months_work_experience
    then_i_see_the(:eligibility_misconduct_page)

    when_i_have_a_misconduct_record
    then_i_see_the(:eligibility_ineligible_page)
    and_i_see_the_ineligible_degree_text
    and_i_see_the_ineligible_qualification_text_with_skip_questions_country
    and_i_see_the_ineligible_degree_text
    and_i_see_the_ineligible_teach_children_text
    and_i_see_the_ineligible_work_experience_text
    and_i_see_the_ineligible_misconduct_text
  end

  it "handles countries with multiple regions" do
    when_i_visit_the(:eligibility_start_page)
    when_i_press_start_now
    when_i_select_a_multiple_region_country
    then_i_see_the_region_page

    when_i_select_a_region
    then_i_see_the(:eligibility_qualification_page)
  end

  it "happy path when filtering by country requiring qualification for subject" do
    when_i_visit_the(:eligibility_start_page)
    then_i_see_the(:eligibility_start_page)

    when_i_press_start_now
    then_i_see_the(:eligibility_country_page)

    when_i_select_a_qualified_for_subject_country
    then_i_see_the(:eligibility_qualification_page)

    when_i_have_a_qualification
    then_i_see_the(:eligibility_degree_page)

    when_i_have_a_degree
    then_i_see_the(:eligibility_teach_children_page)

    when_i_can_teach_children
    then_i_see_the(:eligibility_qualified_for_subject_page)

    when_i_am_qualified_to_teach_a_relevant_subject
    then_i_see_the(:eligibility_work_experience_page)

    when_i_have_more_than_20_months_work_experience
    then_i_see_the(:eligibility_misconduct_page)

    when_i_dont_have_a_misconduct_record
    then_i_see_the(:eligibility_eligible_page)
  end

  it "ineligible path when filtering by country, not qualified for UK secondary" do
    when_i_visit_the(:eligibility_start_page)
    then_i_see_the(:eligibility_start_page)

    when_i_press_start_now
    then_i_see_the(:eligibility_country_page)

    when_i_select_a_qualified_for_subject_country
    then_i_see_the(:eligibility_qualification_page)

    when_i_have_a_qualification
    then_i_see_the(:eligibility_degree_page)

    when_i_have_a_degree
    then_i_see_the(:eligibility_teach_children_page)

    when_i_cant_teach_children
    then_i_see_the(:eligibility_qualified_for_subject_page)

    when_i_am_qualified_to_teach_a_relevant_subject
    then_i_see_the(:eligibility_work_experience_page)

    when_i_have_more_than_20_months_work_experience
    then_i_see_the(:eligibility_misconduct_page)

    when_i_dont_have_a_misconduct_record
    then_i_see_the(:eligibility_ineligible_page)
  end

  it "ineligible path when filtering by country, not qualified in relevant subject" do
    when_i_visit_the(:eligibility_start_page)
    then_i_see_the(:eligibility_start_page)

    when_i_press_start_now
    then_i_see_the(:eligibility_country_page)

    when_i_select_a_qualified_for_subject_country
    then_i_see_the(:eligibility_qualification_page)

    when_i_have_a_qualification
    then_i_see_the(:eligibility_degree_page)

    when_i_have_a_degree
    then_i_see_the(:eligibility_teach_children_page)

    when_i_can_teach_children
    then_i_see_the(:eligibility_qualified_for_subject_page)

    when_i_am_not_qualified_to_teach_a_relevant_subject
    then_i_see_the(:eligibility_work_experience_page)

    when_i_have_more_than_20_months_work_experience
    then_i_see_the(:eligibility_misconduct_page)

    when_i_dont_have_a_misconduct_record
    then_i_see_the(:eligibility_ineligible_page)
  end

  it "ineligible path when filtering by country, not qualified in relevant subject" do
    when_i_visit_the(:eligibility_start_page)
    then_i_see_the(:eligibility_start_page)

    when_i_press_start_now
    then_i_see_the(:eligibility_country_page)

    when_i_select_an_ineligible_country
    then_i_see_the(:eligibility_ineligible_page)

    when_i_visit_the(:eligibility_qualification_page)
    then_i_see_the(:eligibility_ineligible_page)
  end

  private

  def then_access_is_denied
    expect(page).to have_content("HTTP Basic: Access denied")
  end

  def given_countries_exist
    create(:country, :with_national_region, code: "GB-SCT")
    create(
      :country,
      :with_national_region,
      code: "PT",
      eligibility_skip_questions: true,
    )

    it = create(:country, code: "IT")
    create(:region, country: it, name: "Region")
    create(:region, country: it, name: "Other Region")
    create(:country, :with_national_region, :subject_limited, code: "JM")
  end

  def then_i_do_not_see_the_start_page
    expect(eligibility_start_page).not_to be_displayed
  end

  def when_i_press_start_now
    eligibility_start_page.start_button.click
  end

  def when_i_select_an_eligible_country
    eligibility_country_page.submit(country: "Scotland")
  end

  def when_i_select_an_ineligible_country
    eligibility_country_page.submit(country: "Spain")
  end

  def when_i_select_a_skip_questions_country
    eligibility_country_page.submit(country: "Portugal")
  end

  def when_i_select_a_multiple_region_country
    eligibility_country_page.submit(country: "Italy")
  end

  def when_i_select_england
    eligibility_country_page.submit(country: "England")
  end

  def when_i_select_wales
    eligibility_country_page.submit(country: "Wales")
  end

  def when_i_select_nigeria
    eligibility_country_page.submit(country: "Nigeria")
  end

  def when_i_select_laos
    eligibility_country_page.submit(country: "Laos")
  end

  def when_i_dont_select_a_country
    eligibility_country_page.form.continue_button.click
  end

  def when_i_select_a_qualified_for_subject_country
    eligibility_country_page.submit(country: "Jamaica")
  end

  def then_i_see_the_country_error_message
    expect(eligibility_country_page).to have_error_summary
    expect(eligibility_country_page.error_summary.body).to have_content(
      "Tell us where you’re currently recognised as a teacher",
    )
  end

  def then_i_see_the_region_page
    expect(eligibility_region_page).to have_title(
      "In which state/territory are you currently recognised as a teacher?",
    )
    expect(eligibility_region_page.heading).to have_content(
      "In which state/territory are you currently recognised as a teacher?",
    )
  end

  def when_i_select_a_region
    eligibility_region_page.submit(region: "Region")
  end

  def when_i_have_a_qualification
    eligibility_qualification_page.submit_yes
  end

  def when_i_dont_have_a_qualification
    eligibility_qualification_page.submit_no
  end

  def when_i_have_a_degree
    eligibility_degree_page.submit_yes
  end

  def when_i_dont_have_a_degree
    eligibility_degree_page.submit_no
  end

  def when_i_can_teach_children
    eligibility_teach_children_page.submit_yes
  end

  def when_i_cant_teach_children
    eligibility_teach_children_page.submit_no
  end

  def when_i_am_qualified_to_teach_a_relevant_subject
    eligibility_qualified_for_subject_page.submit_yes
  end

  def when_i_am_not_qualified_to_teach_a_relevant_subject
    eligibility_qualified_for_subject_page.submit_no
  end

  def when_i_have_more_than_20_months_work_experience
    eligibility_work_experience_page.submit_over_20_months
  end

  def when_i_have_under_9_months_work_experience
    eligibility_work_experience_page.submit_under_9_months
  end

  def when_i_have_a_misconduct_record
    eligibility_misconduct_page.submit_yes
  end

  def when_i_dont_have_a_misconduct_record
    eligibility_misconduct_page.submit_no
  end

  def when_i_press_apply
    eligibility_eligible_page.apply_button.click
  end

  def and_i_see_the_ineligible_country_text
    expect(eligibility_ineligible_page.heading.text).to eq(
      "You’re not eligible to apply for qualified teacher status (QTS) in England",
    )
    expect(eligibility_ineligible_page.body).to have_content(
      "If you are recognised as a teacher in Spain you are not currently eligible to use this service.",
    )
  end

  def and_i_see_the_ineligible_england_or_wales_text
    expect(eligibility_ineligible_page.heading.text).to eq(
      "You’re not eligible to apply for qualified teacher status (QTS) in England",
    )
    expect(eligibility_ineligible_page.body).to have_content(
      "This service is for qualified teachers who trained to teach outside of England",
    )
  end

  def and_i_see_the_ineligible_misconduct_text
    expect(eligibility_ineligible_page.reasons).to have_content(
      "To teach in England, you must not have any findings of misconduct or restrictions on your employment record.",
    )
  end

  def and_i_see_the_ineligible_teach_children_text
    expect(eligibility_ineligible_page.reasons).to have_content(
      "You are not qualified to teach children who are aged somewhere between 5 and 16 years.",
    )
  end

  def and_i_see_the_ineligible_work_experience_text
    expect(eligibility_ineligible_page.reasons).to have_content(
      "You do not have sufficient work experience as a teacher.",
    )
  end

  def and_i_see_the_ineligible_qualification_text_with_eligible_country
    expect(eligibility_ineligible_page.reasons).to have_content(
      "You have not completed a formal teaching qualification in Scotland, for example, an undergraduate teaching " \
        "degree or postgraduate teaching qualification.",
    )
  end

  def and_i_see_the_ineligible_qualification_text_with_skip_questions_country
    expect(eligibility_ineligible_page.reasons).to have_content(
      "You have not completed a formal teaching qualification in Portugal, for example, an undergraduate teaching " \
        "degree or postgraduate teaching qualification.",
    )
  end

  def and_i_see_the_ineligible_degree_text
    expect(eligibility_ineligible_page.reasons).to have_content(
      "You do not have a degree.",
    )
  end

  def when_i_press_back
    click_link "Back"
  end

  def then_i_have_two_eligibility_checks
    expect(EligibilityCheck.count).to eq(2)
  end
end
