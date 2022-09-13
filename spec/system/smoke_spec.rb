# frozen_string_literal: true

require "spec_helper"
require "capybara/rspec"
require "capybara/cuprite"
require "site_prism"
require "site_prism/all_there"

require "support/autoload/page_objects/eligibility_interface/country"
require "support/autoload/page_objects/eligibility_interface/degree"
require "support/autoload/page_objects/eligibility_interface/eligible"
require "support/autoload/page_objects/eligibility_interface/misconduct"
require "support/autoload/page_objects/eligibility_interface/qualification"
require "support/autoload/page_objects/eligibility_interface/region"
require "support/autoload/page_objects/eligibility_interface/start"
require "support/autoload/page_objects/eligibility_interface/teach_children"

Capybara.javascript_driver = :cuprite
Capybara.always_include_port = false

describe "Smoke test", type: :system, js: true, smoke_test: true do
  before do
    page.driver.basic_authorize(
      ENV["SUPPORT_USERNAME"],
      ENV["SUPPORT_PASSWORD"]
    )
  end

  it "runs" do
    when_i_visit_the_service_domain
    and_i_click_the_start_button
    and_i_need_to_check_my_eligibility
    and_i_enter_a_country
    and_i_select_a_state
    and_i_have_a_teaching_qualification
    and_i_have_a_university_degree
    and_i_am_qualified_to_teach
    and_i_dont_have_sanctions
    then_i_should_be_eligible_to_apply
  end

  private

  def when_i_visit_the_service_domain
    page.visit(ENV["HOSTING_DOMAIN"])
  end

  def and_i_click_the_start_button
    start_page.start_button.click
  end

  def and_i_need_to_check_my_eligibility
    # dev & test environments have this feature enabled currently but production does
    # not. We can remove this conditional when the feature is released
    if page.has_content?("Have you used the service before?")
      choose "No, I need to check my eligibility", visible: false
      click_button "Continue"
    end
  end

  def and_i_enter_a_country
    country_page.submit(country: "Canada")
  end

  def and_i_select_a_state
    region_page.submit(region: "Ontario")
  end

  def and_i_have_a_teaching_qualification
    qualification_page.submit_yes
  end

  def and_i_have_a_university_degree
    degree_page.submit_yes
  end

  def and_i_am_qualified_to_teach
    teach_children_page.submit_yes
  end

  def and_i_dont_have_sanctions
    misconduct_page.submit_no
  end

  def then_i_should_be_eligible_to_apply
    expect(eligible_page).to have_content("You’re eligible to apply")
  end

  def start_page
    @start_page ||= PageObjects::EligibilityInterface::Start.new
  end

  def country_page
    @country_page ||= PageObjects::EligibilityInterface::Country.new
  end

  def region_page
    @region_page ||= PageObjects::EligibilityInterface::Region.new
  end

  def qualification_page
    @qualification_page ||= PageObjects::EligibilityInterface::Qualification.new
  end

  def degree_page
    @degree_page ||= PageObjects::EligibilityInterface::Degree.new
  end

  def teach_children_page
    @teach_children_page ||=
      PageObjects::EligibilityInterface::TeachChildren.new
  end

  def misconduct_page
    @misconduct_page ||= PageObjects::EligibilityInterface::Misconduct.new
  end

  def eligible_page
    @eligible_page ||= PageObjects::EligibilityInterface::Eligible.new
  end
end
