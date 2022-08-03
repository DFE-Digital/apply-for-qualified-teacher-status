# frozen_string_literal: true
require "spec_helper"
require "capybara/rspec"
require "capybara/cuprite"

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
    click_button("Start now")
  end

  def and_i_need_to_check_my_eligibility
    # dev & test environments have this feature enabled currently but production does
    # not. We can remove this conditional when the feature is released
    if page.has_content?("Have you used the service before?")
      choose "No, I need to check my eligibility", visible: false
      continue
    end
  end

  def and_i_enter_a_country
    fill_in "eligibility-interface-country-form-location-field", with: "Canada"
    continue
  end

  def and_i_select_a_state
    choose "Ontario", visible: false
    continue
  end

  def and_i_have_a_teaching_qualification
    choose "Yes", visible: false
    continue
  end

  def and_i_have_a_university_degree
    choose "Yes", visible: false
    continue
  end

  def and_i_am_qualified_to_teach
    choose "Yes", visible: false
    continue
  end

  def and_i_dont_have_sanctions
    choose "No", visible: false
    continue
  end

  def then_i_should_be_eligible_to_apply
    expect(page).to have_content("You’re eligible to apply")
  end

  private

  def continue
    click_button("Continue")
  end
end
