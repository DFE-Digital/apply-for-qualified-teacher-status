# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor listing application forms", type: :system do
  before do
    given_the_service_is_staff_http_basic_auth
    given_there_are_application_forms

    when_i_am_authorized_as_an_assessor_user
  end

  it "displays a list of applications" do
    when_i_visit_the(:applications_page)
    then_i_see_a_list_of_applications
  end

  it "paginates the results" do
    when_i_visit_the(:applications_page)
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

  def when_i_click_on_next
    applications_page.pagination.next.click
  end

  def then_i_see_a_list_of_applications
    page_one_names =
      application_forms[0..19].map do |application_form|
        "#{application_form.given_names} #{application_form.family_name}"
      end

    expect(page_one_names).to eq(visible_names)
  end

  def then_i_see_the_pagination_controls
    expect(applications_page.pagination).to be_visible
  end

  def then_i_see_the_next_page_of_applications
    page_two_names =
      application_forms[20..24].map do |application_form|
        "#{application_form.given_names} #{application_form.family_name}"
      end

    expect(page_two_names).to eq(visible_names)
  end

  def visible_names
    applications_page.search_results.map { |result| result.name.text }
  end

  def application_forms
    @application_forms ||=
      create_list(
        :application_form,
        25,
        :with_personal_information,
        :submitted,
      ).sort_by(&:submitted_at)
  end
end
