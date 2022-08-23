# frozen_string_literal: true

RSpec.describe "Personas", type: :system do
  before { given_the_service_is_open }

  context "active" do
    before { given_personas_are_activated }

    it "without personas" do
      when_i_visit_the_personas_page
      then_i_see_the_personas_page
      and_i_see_no_personas
    end

    it "with personas" do
      given_personas_exist

      when_i_visit_the_personas_page
      then_i_see_the_personas_page
      and_i_see_some_personas

      when_i_sign_in_as_a_staff_persona
      then_i_see_the_case_management_page

      when_i_visit_the_personas_page

      when_i_sign_in_as_a_teacher_persona
      then_i_see_the_application_form_page
    end
  end

  it "inactive" do
    given_personas_are_deactivated

    when_i_visit_the_personas_page
    then_i_see_the_start_page
    and_i_see_the_feature_disabled_message
  end

  private

  def given_personas_are_activated
    FeatureFlag.activate(:personas)
  end

  def given_personas_are_deactivated
    FeatureFlag.deactivate(:personas)
  end

  def given_personas_exist
    create(:staff, :confirmed, email: "staff@example.com")
    create(:teacher, :confirmed, email: "teacher@example.com")
  end

  def when_i_visit_the_personas_page
    visit :personas
  end

  def when_i_sign_in_as_a_staff_persona
    click_button "Sign in as staff@example.com"
  end

  def when_i_sign_in_as_a_teacher_persona
    click_button "Sign in as teacher@example.com"
  end

  def then_i_see_the_personas_page
    expect(page).to have_title("Personas")
    expect(page).to have_content("Personas")
    expect(page).to have_content("Staff")
    expect(page).to have_content("Teachers")
  end

  def then_i_see_the_case_management_page
    expect(page).to have_content("Application forms")
  end

  def then_i_see_the_application_form_page
    expect(page).to have_content(
      "In which country are you currently recognised as a teacher?"
    )
  end

  def then_i_see_the_start_page
    expect(page).to have_content(
      "Check your eligibility to apply for qualified teacher status (QTS) in England"
    )
  end

  def and_i_see_no_personas
    expect(page).to have_content("No staff personas.")
    expect(page).to have_content("No teacher personas.")
  end

  def and_i_see_some_personas
    expect(page).to have_content("staff@example.com")
    expect(page).to have_content("teacher@example.com")
  end

  def and_i_see_the_feature_disabled_message
    expect(page).to have_content("Personas feature not active.")
  end
end
