# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Personas", type: :system do
  before { given_the_service_is_open }

  context "active" do
    before { given_personas_are_activated }

    it "without personas" do
      when_i_visit_the(:personas_page)
      then_i_see_the(:personas_page)
      and_i_see_no_personas
    end

    it "with personas" do
      given_personas_exist

      when_i_visit_the(:personas_page)
      then_i_see_the(:personas_page)
      and_i_see_some_personas

      when_i_sign_in_as_a_staff_persona
      then_i_see_the(:assessor_applications_page)

      when_i_visit_the(:personas_page)

      when_i_sign_in_as_an_eligible_persona
      then_i_see_the(:eligibility_eligible_page)

      when_i_visit_the(:personas_page)

      when_i_sign_in_as_an_ineligible_persona
      then_i_see_the(:eligibility_ineligible_page)

      when_i_visit_the(:personas_page)

      when_i_sign_in_as_a_teacher_persona
      then_i_see_the(:teacher_application_page)

      when_i_visit_the(:personas_page)
    end
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

    create(:staff, :confirmed, email: "staff@example.com")

    teacher = create(:teacher, email: "teacher@example.com")
    create(:application_form, teacher:)
  end

  def when_i_sign_in_as_a_staff_persona
    personas_page.staff.buttons.first.click
  end

  def when_i_sign_in_as_an_eligible_persona
    personas_page.eligibles.buttons.first.click
  end

  def when_i_sign_in_as_an_ineligible_persona
    personas_page.ineligibles.buttons.first.click
  end

  def when_i_sign_in_as_a_teacher_persona
    personas_page.teachers.buttons.first.click
  end

  def and_i_see_no_personas
    expect(personas_page.eligibles).to have_content("No eligible personas.")
    expect(personas_page.staff).to have_content("No staff personas.")
    expect(personas_page.teachers).to have_content("No teacher personas.")
  end

  def and_i_see_some_personas
    expect(personas_page.eligibles).to have_content("Example Region")
    expect(personas_page.staff).to have_content("staff@example.com")
    expect(personas_page.teachers).to have_content("teacher@example.com")
  end

  def and_i_see_the_feature_disabled_message
    expect(personas_page).to have_content("Personas feature not active.")
  end
end
