# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor filtering application forms", type: :system do
  before do
    given_the_service_is_open
    given_there_are_application_forms
    given_i_am_authorized_as_an_assessor_user
  end

  it "applies the filters" do
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
    and_i_apply_the_email_filter
    then_i_see_a_list_of_applications_filtered_by_email

    when_i_clear_the_filters
    and_i_apply_the_submitted_at_filter
    then_i_see_a_list_of_applications_filtered_by_submitted_at

    when_i_clear_the_filters
    and_i_apply_the_action_required_by_filter
    then_i_see_a_list_of_applications_filtered_by_action_required_by

    when_i_clear_the_filters
    and_i_apply_the_status_filter
    then_i_see_a_list_of_applications_filtered_by_state
  end

  private

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
    expect(applications_page.assessor_filter.assessors.count).to eq(4)
    applications_page.assessor_filter.assessors.second.checkbox.click
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

  def and_i_apply_the_email_filter
    applications_page.email_filter.email.set("emma.dubois@example.org")
    applications_page.apply_filters.click
  end

  def then_i_see_a_list_of_applications_filtered_by_email
    expect(applications_page.search_results.count).to eq(1)
    expect(applications_page.search_results.first.name.text).to eq(
      "Emma Dubois",
    )
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

  def and_i_apply_the_action_required_by_filter
    admin_action_item =
      applications_page.action_required_by_filter.items.find do |item|
        item.label.text == "Admin (1)"
      rescue Capybara::ElementNotFound
        false
      end
    admin_action_item.checkbox.click
    applications_page.apply_filters.click
  end

  def then_i_see_a_list_of_applications_filtered_by_action_required_by
    expect(applications_page.search_results.count).to eq(1)
    expect(applications_page.search_results.first.name.text).to eq(
      "Emma Dubois",
    )
  end

  def and_i_apply_the_status_filter
    awarded_state =
      applications_page.status_filter.statuses.find do |status|
        status.label.text == "Awarded (1)"
      rescue Capybara::ElementNotFound
        false
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
        assessor: assessors.second,
        submitted_at: Date.new(2019, 12, 1),
        reference: "CHERBERT",
      ),
      create(
        :application_form,
        :submitted,
        :action_required_by_admin,
        region: create(:region, country: create(:country, code: "FR")),
        given_names: "Emma",
        family_name: "Dubois",
        assessor: assessors.second,
        submitted_at: Date.new(2019, 12, 1),
        teacher: create(:teacher, email: "emma.dubois@example.org"),
      ),
      create(
        :application_form,
        :submitted,
        :action_required_by_assessor,
        region: create(:region, country: create(:country, code: "ES")),
        given_names: "Arnold",
        family_name: "Drummond",
        assessor: assessors.first,
        submitted_at: Date.new(2019, 12, 1),
      ),
      create(
        :application_form,
        :awarded,
        region: create(:region, country: create(:country, code: "PT")),
        given_names: "John",
        family_name: "Smith",
        assessor: assessors.second,
        submitted_at: Date.new(2020, 1, 1),
      ),
    ]
  end

  def assessors
    @assessors ||= [
      create(:staff, :with_award_decline_permission, name: "Fal Staff"),
      create(:staff, :with_award_decline_permission, name: "Wag Staff"),
    ]
  end
end
