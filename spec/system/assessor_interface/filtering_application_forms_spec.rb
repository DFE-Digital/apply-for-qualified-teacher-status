# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor filtering application forms", type: :system do
  it "applies the filters" do
    given_the_service_is_staff_http_basic_auth
    given_there_are_application_forms

    when_i_am_authorized_as_an_assessor_user
    when_i_visit_the(:applications_page)

    when_i_clear_the_filters
    and_i_apply_the_assessor_filter
    then_i_see_a_list_of_applications_filtered_by_assessor

    when_i_clear_the_filters
    and_i_apply_the_country_filter
    then_i_see_a_list_of_applications_filtered_by_country

    when_i_clear_the_filters
    and_i_apply_the_reference_filter
    then_i_see_a_list_of_applications_filtered_by_reference

    when_i_clear_the_filters
    and_i_apply_the_name_filter
    then_i_see_a_list_of_applications_filtered_by_name

    when_i_clear_the_filters
    and_i_apply_the_submitted_at_filter
    then_i_see_a_list_of_applications_filtered_by_submitted_at

    when_i_clear_the_filters
    and_i_apply_the_state_filter
    then_i_see_a_list_of_applications_filtered_by_state
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

  def when_i_clear_the_filters
    applications_page.clear_filters.click
  end

  def and_i_apply_the_assessor_filter
    applications_page.assessor_filter.assessors.first.checkbox.click
    applications_page.apply_filters.click
  end

  def then_i_see_a_list_of_applications_filtered_by_assessor
    expect(applications_page.search_results.count).to eq(1)
    expect(applications_page.search_results.first.name.text).to eq(
      "Arnold Drummond",
    )
  end

  def and_i_apply_the_country_filter
    applications_page.country_filter.country.set("France")
    applications_page.apply_filters.click
  end

  def then_i_see_a_list_of_applications_filtered_by_country
    expect(applications_page.search_results.count).to eq(1)
    expect(applications_page.search_results.first.name.text).to eq(
      "Emma Dubois",
    )
  end

  def and_i_apply_the_reference_filter
    applications_page.reference_filter.reference.set("CHER")
    applications_page.apply_filters.click
  end

  def then_i_see_a_list_of_applications_filtered_by_reference
    expect(applications_page.search_results.count).to eq(1)
    expect(applications_page.search_results.first.name.text).to eq("Cher Bert")
  end

  def and_i_apply_the_name_filter
    applications_page.name_filter.name.set("cher")
    applications_page.apply_filters.click
  end

  def then_i_see_a_list_of_applications_filtered_by_name
    expect(applications_page.search_results.count).to eq(1)
    expect(applications_page.search_results.first.name.text).to eq("Cher Bert")
  end

  def and_i_apply_the_submitted_at_filter
    applications_page.submitted_at_filter.start_day.set(1)
    applications_page.submitted_at_filter.start_month.set(1)
    applications_page.submitted_at_filter.start_year.set(2020)
    applications_page.apply_filters.click
  end

  def then_i_see_a_list_of_applications_filtered_by_submitted_at
    expect(applications_page.search_results.count).to eq(1)
    expect(applications_page.search_results.first.name.text).to eq("John Smith")
  end

  def and_i_apply_the_state_filter
    awarded_state =
      applications_page.state_filter.states.find do |state|
        state.label.text == "Awarded (1)"
      end
    awarded_state.checkbox.click
    applications_page.apply_filters.click
  end

  def then_i_see_a_list_of_applications_filtered_by_state
    expect(applications_page.search_results.count).to eq(1)
    expect(applications_page.search_results.first.name.text).to eq("John Smith")
  end

  def application_forms
    @application_forms ||= [
      create(
        :application_form,
        :submitted,
        region: create(:region, country: create(:country, code: "US")),
        given_names: "Cher",
        family_name: "Bert",
        submitted_at: Date.new(2019, 12, 1),
        reference: "CHERBERT",
      ),
      create(
        :application_form,
        :submitted,
        region: create(:region, country: create(:country, code: "FR")),
        given_names: "Emma",
        family_name: "Dubois",
        submitted_at: Date.new(2019, 12, 1),
      ),
      create(
        :application_form,
        :submitted,
        given_names: "Arnold",
        family_name: "Drummond",
        assessor: assessors.first,
        submitted_at: Date.new(2019, 12, 1),
      ),
      create(
        :application_form,
        :awarded,
        given_names: "John",
        family_name: "Smith",
        submitted_at: Date.new(2020, 1, 1),
      ),
    ]
  end

  def assessors
    [create(:staff, :assessor, name: "Wag Staff"), create(:staff, :assessor, name: "Fal Staff")]
  end
end
