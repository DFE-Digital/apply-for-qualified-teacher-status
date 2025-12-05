# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher reapply", type: :system do
  around do |example|
    FeatureFlags::FeatureFlag.activate(:teacher_applications)

    given_i_am_authorized_as_a_user(teacher)
    given_there_is_an_application_form
    given_countries_exist
    example.run

    FeatureFlags::FeatureFlag.deactivate(:teacher_applications)
  end

  it "allows reapplying" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_declined_application_page)

    when_i_click_check_eligibility_again
    then_i_see_the(:eligibility_country_page)

    when_i_select_an_eligible_country
    then_i_see_the(:eligibility_qualification_page)

    when_i_have_a_qualification
    then_i_see_the(:eligibility_degree_page)

    when_i_have_a_degree
    then_i_see_the(:eligibility_work_experience_page)

    when_i_have_more_than_20_months_work_experience
    then_i_see_the(:eligibility_misconduct_page)

    when_i_dont_have_a_misconduct_record
    then_i_see_the(:eligibility_teach_children_page)

    when_i_can_teach_children
    then_i_see_the(:eligibility_eligible_page)
    and_i_see_the_start_new_application_button

    when_i_click_start_new_application
    then_i_see_the(:teacher_application_page)
  end

  def given_there_is_an_application_form
    application_form
  end

  def when_i_select_an_eligible_country
    eligibility_country_page.submit(country: "Scotland")
  end

  def when_i_have_a_qualification
    eligibility_qualification_page.submit_yes
  end

  def when_i_click_check_eligibility_again
    teacher_declined_application_page.apply_check_eligibility_again_button.click
  end

  def when_i_have_a_degree
    eligibility_degree_page.submit_yes
  end

  def when_i_have_more_than_20_months_work_experience
    eligibility_work_experience_page.submit_over_20_months
  end

  def when_i_dont_have_a_misconduct_record
    eligibility_misconduct_page.submit_no
  end

  def and_i_see_the_start_new_application_button
    expect(eligibility_eligible_page).to have_button("Start a new application")
  end

  def when_i_click_start_new_application
    eligibility_eligible_page.apply_button.click
  end

  def when_i_can_teach_children
    eligibility_teach_children_page.submit_yes
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def given_countries_exist
    create(:country, :with_national_region, code: "GB-SCT")
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :declined,
        teacher:,
        region: create(:region, :national),
        assessment: create(:assessment),
      )
  end
end
