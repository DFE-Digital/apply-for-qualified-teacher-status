# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Personas", type: :system do
  it "active" do
    given_personas_are_activated
    given_personas_exist

    when_i_visit_the(:personas_page)
    then_i_see_the(:personas_page)

    when_i_click_on_the_staff_tab_item
    and_i_sign_in_as_a_persona
    then_i_see_the(:assessor_applications_page)

    when_i_visit_the(:personas_page)

    when_i_click_on_the_eligible_checks_tab_item
    and_i_sign_in_as_a_persona
    then_i_see_the(:eligibility_eligible_page)

    when_i_visit_the(:personas_page)

    when_i_click_on_the_ineligible_checks_tab_item
    and_i_sign_in_as_a_persona
    then_i_see_the(:eligibility_ineligible_page)

    when_i_visit_the(:personas_page)

    when_i_click_on_the_teachers_tab_item
    and_i_sign_in_as_a_persona
    then_i_see_the(:teacher_application_page)

    when_i_visit_the(:personas_page)
  end

  it "inactive" do
    given_personas_are_deactivated

    when_i_visit_the(:personas_page)
    then_i_see_the(:eligibility_start_page)
    and_i_see_the_feature_disabled_message
  end

  private

  def given_personas_are_activated
    FeatureFlags::FeatureFlag.activate(:personas)
  end

  def given_personas_are_deactivated
    FeatureFlags::FeatureFlag.deactivate(:personas)
  end

  def given_personas_exist
    create(:region, :online_checks, name: "Example Region")

    create(:staff, email: "staff@example.com")

    teacher = create(:teacher, email: "teacher@example.com")
    create(:application_form, teacher:)
  end

  def when_i_click_on_the_staff_tab_item
    personas_page.staff_tab_item.click
  end

  def when_i_click_on_the_eligible_checks_tab_item
    personas_page.eligible_checks_tab_item.click
  end

  def when_i_click_on_the_ineligible_checks_tab_item
    personas_page.ineligible_checks_tab_item.click
  end

  def when_i_click_on_the_teachers_tab_item
    personas_page.teachers_tab_item.click
  end

  def and_i_sign_in_as_a_persona
    personas_page.tabs.panel.buttons.first.click
  end

  def and_i_see_the_feature_disabled_message
    expect(personas_page).to have_content("Personas feature not active.")
  end
end
