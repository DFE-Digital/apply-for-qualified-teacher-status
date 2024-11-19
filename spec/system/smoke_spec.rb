# frozen_string_literal: true

require "spec_helper"
require "capybara/rspec"
require "capybara/cuprite"
require "site_prism"
require "site_prism/all_there"

require "support/autoload/page_objects/govuk_error_summary"
require "support/autoload/page_objects/govuk_radio_item"
require "support/autoload/page_objects/eligibility_interface/question"
require "support/autoload/page_objects/eligibility_interface/country"
require "support/autoload/page_objects/eligibility_interface/degree"
require "support/autoload/page_objects/eligibility_interface/eligible"
require "support/autoload/page_objects/eligibility_interface/misconduct"
require "support/autoload/page_objects/eligibility_interface/qualification"
require "support/autoload/page_objects/eligibility_interface/region"
require "support/autoload/page_objects/eligibility_interface/start"
require "support/autoload/page_objects/eligibility_interface/teach_children"
require "support/autoload/page_objects/eligibility_interface/work_experience"

Capybara.javascript_driver = :cuprite
Capybara.always_include_port = false

describe "Smoke test", :js, :smoke_test, type: :system do
  before do
    page.driver.basic_authorize(ENV["SMOKE_USERNAME"], ENV["SMOKE_PASSWORD"])
  end

  it "runs" do
    when_i_visit_the_service_domain
    and_i_click_the_start_button
    and_i_need_to_check_my_eligibility
    and_i_enter_a_country
    and_i_select_a_state
    and_i_have_a_teaching_qualification
    and_i_have_a_university_degree
    and_i_am_qualified_to_teach_children
    and_i_have_work_experience
    and_i_dont_have_sanctions
    then_i_should_be_eligible_to_apply
  end

  private

  def when_i_visit_the_service_domain
    page.visit(ENV["SMOKE_URL"])
  end

  def and_i_click_the_start_button
    eligibility_start_page.start_button.click
  end

  def and_i_need_to_check_my_eligibility
    # dev & test environments have this feature enabled currently but production does
    # not. We can remove this conditional when the feature is released
    if page.has_content?("Have you used the service before?")
      if page.has_content?("No, I need to check my eligibility")
        choose "No, I need to check my eligibility", visible: false
      else
        choose "No, I need to check if I can apply", visible: false
      end
      click_button "Continue"
    end
  end

  def and_i_enter_a_country
    eligibility_country_page.submit(country: "Canada")
  end

  def and_i_select_a_state
    eligibility_region_page.submit(region: "Ontario")
  end

  def and_i_have_a_teaching_qualification
    eligibility_qualification_page.submit_yes
  end

  def and_i_have_a_university_degree
    eligibility_degree_page.submit_yes
  end

  def and_i_am_qualified_to_teach_children
    eligibility_teach_children_page.submit_yes
  end

  def and_i_have_work_experience
    # dev & test environments have this feature enabled currently but production does
    # not. We can remove this conditional when the feature is released
    if page.has_content?("How long have you worked as a recognised teacher?")
      eligibility_work_experience_page.submit_over_20_months
    end
  end

  def and_i_dont_have_sanctions
    eligibility_misconduct_page.submit_no
  end

  def then_i_should_be_eligible_to_apply
    expect(eligibility_eligible_page).to have_content(
      "You’re eligible to apply",
    )
  end

  def eligibility_start_page
    @eligibility_start_page ||= PageObjects::EligibilityInterface::Start.new
  end

  def eligibility_country_page
    @eligibility_country_page ||= PageObjects::EligibilityInterface::Country.new
  end

  def eligibility_region_page
    @eligibility_region_page ||= PageObjects::EligibilityInterface::Region.new
  end

  def eligibility_qualification_page
    @eligibility_qualification_page ||=
      PageObjects::EligibilityInterface::Qualification.new
  end

  def eligibility_degree_page
    @eligibility_degree_page ||= PageObjects::EligibilityInterface::Degree.new
  end

  def eligibility_teach_children_page
    @eligibility_teach_children_page ||=
      PageObjects::EligibilityInterface::TeachChildren.new
  end

  def eligibility_work_experience_page
    @eligibility_work_experience_page ||=
      PageObjects::EligibilityInterface::WorkExperience.new
  end

  def eligibility_misconduct_page
    @eligibility_misconduct_page ||=
      PageObjects::EligibilityInterface::Misconduct.new
  end

  def eligibility_eligible_page
    @eligibility_eligible_page ||=
      PageObjects::EligibilityInterface::Eligible.new
  end
end
