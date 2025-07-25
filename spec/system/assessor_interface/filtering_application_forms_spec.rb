# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor filtering application forms", type: :system do
  let(:assessors) do
    [
      create(:staff, :with_assess_permission, name: "Fal Staff"),
      create(:staff, :with_assess_permission, name: "Wag Staff"),
    ]
  end

  before do
    given_there_are_application_forms
    given_i_am_authorized_as_an_assessor_user
  end

  it "applies the filters" do
    when_i_visit_the(:assessor_applications_page)

    when_i_clear_the_filters
    then_i_see_applications_in_the_last_90_days

    when_i_clear_the_filters
    and_i_apply_the_assessor_filter
    then_i_see_a_list_of_applications_filtered_by_assessor

    when_i_clear_the_filters
    and_i_apply_the_statuses_filter
    then_i_see_a_list_of_applications_filtered_by_status

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
    and_i_apply_the_stage_filter
    then_i_see_a_list_of_applications_filtered_by_stage

    when_i_clear_the_filters
    and_i_apply_the_prioritised_filter
    then_i_see_a_list_of_applications_filtered_by_prioritised

    when_i_clear_the_filters
    and_i_apply_the_show_all_filter
    then_i_see_a_list_of_all_applications

    when_i_clear_the_filters
    and_i_apply_the_date_of_birth_filter
    then_i_see_a_list_of_applications_filtered_by_date_of_birth
  end

  private

  def given_there_are_application_forms
    create(
      :application_form,
      :submitted,
      :with_assessment,
      region: create(:region, :in_country, country_code: "US"),
      given_names: "Cher",
      family_name: "Bert",
      date_of_birth: Date.new(2000, 1, 1),
      assessor: assessors.second,
      submitted_at: 2.months.ago,
      reference: "CHERBERT",
    )

    create(
      :application_form,
      :submitted,
      :with_assessment,
      :action_required_by_admin,
      region: create(:region, :in_country, country_code: "FR"),
      given_names: "Emma",
      family_name: "Dubois",
      assessor: assessors.second,
      submitted_at: 2.months.ago,
      teacher: create(:teacher, email: "emma.dubois@example.org"),
    )

    create(
      :application_form,
      :submitted,
      :with_assessment,
      :action_required_by_assessor,
      region: create(:region, :in_country, country_code: "ES"),
      given_names: "Arnold",
      family_name: "Drummond",
      assessor: assessors.first,
      submitted_at: 2.months.ago,
    )

    create(
      :application_form,
      :awarded,
      :with_assessment,
      awarded_at: 2.days.ago,
      region: create(:region, :in_country, country_code: "PT"),
      given_names: "John",
      family_name: "Smith",
      assessor: assessors.second,
      submitted_at: 10.days.ago,
    )

    create(
      :application_form,
      :submitted,
      :with_assessment,
      region: create(:region, :in_country, country_code: "DE"),
      given_names: "Prioritised",
      family_name: "Applicant",
      assessor: assessors.second,
      submitted_at: 20.days.ago,
    ).tap do |application_form|
      application_form.assessment.update!(prioritised: true)
    end

    create(
      :application_form,
      :awarded,
      :with_assessment,
      awarded_at: 6.months.ago,
      region: create(:region, :in_country, country_code: "DE"),
      given_names: "Nick",
      family_name: "Johnson",
      assessor: assessors.second,
      submitted_at: 7.months.ago,
    )
  end

  def when_i_visit_the_applications_page
    visit assessor_interface_application_forms_path
  end

  def when_i_clear_the_filters
    assessor_applications_page.clear_filters.click
  end

  def then_i_see_applications_in_the_last_90_days
    expect(assessor_applications_page.search_results.count).to eq(5)
  end

  def and_i_apply_the_assessor_filter
    expect(assessor_applications_page.assessor_filter.assessors.count).to eq(3)
    assessor_applications_page.assessor_filter.assessors.first.checkbox.click
    assessor_applications_page.apply_filters.click
  end

  def and_i_apply_the_statuses_filter
    expect(assessor_applications_page.statuses_filter.statuses.count).to eq(26)
    assessor_applications_page.statuses_filter.statuses.fourth.checkbox.click
    assessor_applications_page.apply_filters.click
  end

  def then_i_see_a_list_of_applications_filtered_by_assessor
    expect(assessor_applications_page.search_results.count).to eq(1)
    expect(assessor_applications_page.search_results.first.name.text).to eq(
      "Arnold Drummond",
    )
  end

  def then_i_see_a_list_of_applications_filtered_by_status
    expect(assessor_applications_page.search_results.count).to eq(1)
    expect(assessor_applications_page.search_results.first.name.text).to eq(
      "John Smith",
    )
  end

  def and_i_apply_the_country_filter
    assessor_applications_page.country_filter.country.set("France")
    assessor_applications_page.apply_filters.click
  end

  def then_i_see_a_list_of_applications_filtered_by_country
    expect(assessor_applications_page.search_results.count).to eq(1)
    expect(assessor_applications_page.search_results.first.name.text).to eq(
      "Emma Dubois",
    )
  end

  def and_i_apply_the_reference_filter
    assessor_applications_page.reference_filter.reference.set("CHER")
    assessor_applications_page.apply_filters.click
  end

  def then_i_see_a_list_of_applications_filtered_by_reference
    expect(assessor_applications_page.search_results.count).to eq(1)
    expect(assessor_applications_page.search_results.first.name.text).to eq(
      "Cher Bert",
    )
  end

  def and_i_apply_the_name_filter
    assessor_applications_page.name_filter.name.set("cher")
    assessor_applications_page.apply_filters.click
  end

  def then_i_see_a_list_of_applications_filtered_by_name
    expect(assessor_applications_page.search_results.count).to eq(1)
    expect(assessor_applications_page.search_results.first.name.text).to eq(
      "Cher Bert",
    )
  end

  def and_i_apply_the_email_filter
    assessor_applications_page.email_filter.email.set("emma.dubois@example.org")
    assessor_applications_page.apply_filters.click
  end

  def then_i_see_a_list_of_applications_filtered_by_email
    expect(assessor_applications_page.search_results.count).to eq(1)
    expect(assessor_applications_page.search_results.first.name.text).to eq(
      "Emma Dubois",
    )
  end

  def and_i_apply_the_submitted_at_filter
    ten_days_ago = 10.days.ago
    assessor_applications_page.submitted_at_filter.start_day.set(
      ten_days_ago.day,
    )
    assessor_applications_page.submitted_at_filter.start_month.set(
      ten_days_ago.month,
    )
    assessor_applications_page.submitted_at_filter.start_year.set(
      ten_days_ago.year,
    )
    assessor_applications_page.apply_filters.click
  end

  def then_i_see_a_list_of_applications_filtered_by_submitted_at
    expect(assessor_applications_page.search_results.count).to eq(1)
    expect(assessor_applications_page.search_results.first.name.text).to eq(
      "John Smith",
    )
  end

  def and_i_apply_the_stage_filter
    completed_item =
      assessor_applications_page.stage_filter.items.find do |item|
        item.label.text == "Completed (1)"
      rescue Capybara::ElementNotFound
        false
      end
    completed_item.checkbox.click
    assessor_applications_page.apply_filters.click
  end

  def then_i_see_a_list_of_applications_filtered_by_stage
    expect(assessor_applications_page.search_results.count).to eq(1)
    expect(assessor_applications_page.search_results.first.name.text).to eq(
      "John Smith",
    )
  end

  def then_i_see_a_list_of_applications_filtered_by_prioritised
    expect(assessor_applications_page.search_results.count).to eq(1)
    expect(
      assessor_applications_page.search_results.first.name.text,
    ).to include("Prioritised Applicant")
  end

  def and_i_apply_the_show_all_filter
    show_all_item =
      assessor_applications_page.show_all_filter.items.find do |item|
        item.label.text == "Show applications completed over 90 days ago"
      rescue Capybara::ElementNotFound
        false
      end
    show_all_item.checkbox.click
    assessor_applications_page.apply_filters.click
  end

  def and_i_apply_the_prioritised_filter
    prioritised_item =
      assessor_applications_page.flags_filter.items.find do |item|
        item.label.text == "Prioritised (1)"
      rescue Capybara::ElementNotFound
        false
      end
    prioritised_item.checkbox.click
    assessor_applications_page.apply_filters.click
  end

  def then_i_see_a_list_of_all_applications
    expect(assessor_applications_page.search_results.count).to eq(6)
  end

  def then_i_see_a_list_of_applications_filtered_by_date_of_birth
    expect(assessor_applications_page.search_results.count).to eq(1)
    expect(assessor_applications_page.search_results.first.name.text).to eq(
      "Cher Bert",
    )
  end

  def and_i_apply_the_date_of_birth_filter
    assessor_applications_page.date_of_birth_filter.day.set("01")
    assessor_applications_page.date_of_birth_filter.month.set("01")
    assessor_applications_page.date_of_birth_filter.year.set("2000")
    assessor_applications_page.apply_filters.click
  end
end
