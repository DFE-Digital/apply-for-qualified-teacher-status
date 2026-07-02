# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Personas", type: :system do
  context "when personas feature is active" do
    before do
      given_personas_are_activated
      given_personas_exist
    end

    it "returns personas page" do
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

    context "with hosting environment being production" do
      before do
        allow(HostingEnvironment).to receive(:production?).and_return(true)
      end

      it "returns 404" do
        when_i_visit_the(:personas_page)
        then_i_see_page_not_found_error
      end
    end
  end

  context "when personas feature is inactive" do
    before { given_personas_are_deactivated }

    it "returns feature inactive" do
      when_i_visit_the(:personas_page)
      then_i_see_the(:eligibility_start_page)
      and_i_see_the_feature_disabled_message
    end

    context "with hosting environment production" do
      before do
        allow(HostingEnvironment).to receive(:production?).and_return(true)
      end

      it "returns 404" do
        when_i_visit_the(:personas_page)
        then_i_see_page_not_found_error
      end
    end
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

  def then_i_see_page_not_found_error
    expect(page).to have_content("Page not found")
  end
end
