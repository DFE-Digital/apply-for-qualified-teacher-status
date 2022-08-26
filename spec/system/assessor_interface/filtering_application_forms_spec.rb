# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Filtering application forms", type: :system do
  it "applies the filters" do
    given_the_service_is_staff_http_basic_auth
    given_there_are_application_forms

    when_i_am_authorized_as_an_assessor_user
    when_i_visit_the_applications_page

    when_i_apply_the_name_filter
    then_i_see_a_list_of_applications_filtered_by_name

    when_i_apply_the_country_filter
    then_i_see_a_list_of_applications_filtered_by_country
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

  def when_i_apply_the_name_filter
    click_link "Clear selection"
    fill_in "Applicant name", with: "cher"
    click_button "Apply filters"
  end

  def then_i_see_a_list_of_applications_filtered_by_name
    expect(page).to have_content("Cher Bert")
  end

  def when_i_apply_the_country_filter
    click_link "Clear selection"
    fill_in "Country", with: "France"
    click_button "Apply filters"
  end

  def then_i_see_a_list_of_applications_filtered_by_country
    expect(page).to have_content("Emma Dubois")
  end

  def application_forms
    @application_forms ||= [
      create(
        :application_form,
        :submitted,
        region: create(:region, country: create(:country, code: "US")),
        given_names: "Cher",
        family_name: "Bert"
      ),
      create(
        :application_form,
        :submitted,
        region: create(:region, country: create(:country, code: "FR")),
        given_names: "Emma",
        family_name: "Dubois"
      )
    ]
  end
end
