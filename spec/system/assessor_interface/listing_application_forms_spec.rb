# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor listing application forms", type: :system do
  before do
    given_the_service_is_staff_http_basic_auth
    given_there_are_application_forms

    when_i_am_authorized_as_an_assessor_user
  end

  it "displays a list of applications" do
    when_i_visit_the_applications_page
    then_i_see_a_list_of_applications
  end

  it "paginates the results" do
    when_i_visit_the_applications_page
    then_i_see_the_pagination_controls

    when_i_click_on_next
    then_i_see_the_next_page_of_applications
  end

  private

  def given_the_service_is_staff_http_basic_auth
    FeatureFlag.activate(:staff_http_basic_auth)
  end

  def given_there_are_application_forms
    application_forms
  end

  def when_i_visit_the_applications_page
    visit assessor_interface_application_forms_path
  end

  def when_i_click_on_next
    click_link "Next"
  end

  def then_i_see_a_list_of_applications
    application_forms[0..19].each do |application_form|
      expect(page).to have_content(
        "#{application_form.given_names} #{application_form.family_name}"
      )
    end
  end

  def then_i_see_the_pagination_controls
    expect(page).to have_content("1")
    expect(page).to have_content("Next")
  end

  def then_i_see_the_next_page_of_applications
    application_forms[20..24].each do |application_form|
      expect(page).to have_content(
        "#{application_form.given_names} #{application_form.family_name}"
      )
    end
  end

  def application_forms
    @application_forms ||=
      create_list(
        :application_form,
        25,
        :with_personal_information,
        :submitted
      ).sort_by(&:submitted_at)
  end
end
