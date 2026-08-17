# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor view SLA statuses", type: :system do
  let(:uk_region) { create :region, :in_country, country_code: "GB-SCT" }
  let(:france_region) { create :region, :in_country, country_code: "FR" }
  let(:switzerland_region) { create :region, :in_country, country_code: "CH" }
  let(:ghana_region) { create :region, :in_country, country_code: "GH" }

  let!(:ten_day_sla_uk) do
    create :application_form,
           :with_prioritisation_work_history_checks,
           region: uk_region,
           working_days_between_submitted_and_today: 8
  end

  let!(:forty_day_sla_uk) do
    create :application_form,
           :with_assessment,
           :submitted,
           region: uk_region,
           working_days_between_submitted_and_today: 35
  end

  let!(:eighty_day_sla_uk) do
    create :application_form,
           :with_assessment,
           :submitted,
           region: uk_region,
           working_days_between_submitted_and_today: 65
  end

  let!(:ten_day_sla_eu) do
    create :application_form,
           :with_prioritisation_work_history_checks,
           region: france_region,
           working_days_between_submitted_and_today: 8
  end

  let!(:forty_day_sla_eu) do
    create :application_form,
           :with_assessment,
           :submitted,
           region: france_region,
           working_days_between_submitted_and_today: 35
  end

  let!(:eighty_day_sla_eu) do
    create :application_form,
           :with_assessment,
           :submitted,
           region: france_region,
           working_days_between_submitted_and_today: 65
  end

  let!(:ten_day_sla_efta) do
    create :application_form,
           :with_prioritisation_work_history_checks,
           region: switzerland_region,
           working_days_between_submitted_and_today: 10
  end

  let!(:forty_day_sla_efta) do
    create :application_form,
           :with_assessment,
           :submitted,
           region: switzerland_region,
           working_days_between_submitted_and_today: 40
  end

  let!(:eighty_day_sla_efta) do
    create :application_form,
           :with_assessment,
           :submitted,
           region: switzerland_region,
           working_days_between_submitted_and_today: 80
  end

  let!(:ten_day_sla_rest_of_world) do
    create :application_form,
           :with_prioritisation_work_history_checks,
           region: ghana_region,
           working_days_between_submitted_and_today: 10
  end

  let!(:forty_day_sla_rest_of_world) do
    create :application_form,
           :with_assessment,
           :submitted,
           region: ghana_region,
           working_days_between_submitted_and_today: 40
  end

  let!(:eighty_day_sla_rest_of_world) do
    create :application_form,
           :with_assessment,
           :submitted,
           region: ghana_region,
           working_days_between_submitted_and_today: 80
  end

  it "does not allow any access if user is archived" do
    given_i_am_authorized_as_an_archived_assessor_user
    when_i_visit_the(:assessor_sla_index_page)
    then_i_see_the_forbidden_page
  end

  it "allows navigation between different SLA tabs" do
    given_i_am_authorized_as_an_assessor_user
    when_i_visit_the(:assessor_sla_index_page)
    then_i_see_the(:assessor_sla_index_page)
    and_i_see_the_active_10_day_sla_tab_with_all_results

    when_i_click_on_40_day_tab
    then_i_see_the_active_40_day_sla_tab_with_all_results

    when_i_click_on_80_day_tab
    then_i_see_the_active_80_day_sla_tab_with_all_results
  end

  it "allows filtering to remain on switching tab and going to totals" do
    given_i_am_authorized_as_an_assessor_user
    when_i_visit_the(:assessor_sla_index_page)
    then_i_see_the(:assessor_sla_index_page)
    and_i_see_the_active_10_day_sla_tab_with_all_results

    when_filter_by_nearing_breach_status
    then_i_see_list_of_only_ten_day_nearing_breach_applications

    when_i_click_on_40_day_tab
    then_i_see_list_of_only_forty_day_nearing_breach_applications

    when_i_click_on_80_day_tab
    then_i_see_list_of_only_eighty_day_nearing_breach_applications

    when_i_go_to_view_totals_page
    then_i_see_the(:assessor_sla_totals_page)

    when_i_go_to_applications_page
    then_i_see_the(:assessor_sla_index_page)
    then_i_see_list_of_only_ten_day_nearing_breach_applications

    when_i_clear_filters
    then_i_see_the(:assessor_sla_index_page)
    and_i_see_the_active_10_day_sla_tab_with_all_results
  end

  private

  def when_i_click_on_40_day_tab
    assessor_sla_index_page.forty_day_sla_tab.click
  end

  def when_i_click_on_80_day_tab
    assessor_sla_index_page.eighty_day_sla_tab.click
  end

  def and_i_see_the_active_10_day_sla_tab_with_all_results
    expect(assessor_sla_index_page.ten_day_sla_tab["class"]).to include(
      "govuk-tabs__list-item--selected",
    )
    expect(assessor_sla_index_page.forty_day_sla_tab["class"]).not_to include(
      "govuk-tabs__list-item--selected",
    )
    expect(assessor_sla_index_page.eighty_day_sla_tab["class"]).not_to include(
      "govuk-tabs__list-item--selected",
    )
    expect(assessor_sla_index_page).to have_content(ten_day_sla_uk.reference)
    expect(assessor_sla_index_page).to have_content(ten_day_sla_eu.reference)
    expect(assessor_sla_index_page).to have_content(ten_day_sla_efta.reference)
    expect(assessor_sla_index_page).to have_content(
      ten_day_sla_rest_of_world.reference,
    )
  end

  def then_i_see_the_active_40_day_sla_tab_with_all_results
    expect(assessor_sla_index_page.forty_day_sla_tab["class"]).to include(
      "govuk-tabs__list-item--selected",
    )
    expect(assessor_sla_index_page.ten_day_sla_tab["class"]).not_to include(
      "govuk-tabs__list-item--selected",
    )
    expect(assessor_sla_index_page.eighty_day_sla_tab["class"]).not_to include(
      "govuk-tabs__list-item--selected",
    )
    expect(assessor_sla_index_page).to have_content(forty_day_sla_uk.reference)
    expect(assessor_sla_index_page).to have_content(forty_day_sla_eu.reference)
    expect(assessor_sla_index_page).to have_content(
      forty_day_sla_efta.reference,
    )
    expect(assessor_sla_index_page).to have_content(
      forty_day_sla_rest_of_world.reference,
    )
  end

  def then_i_see_the_active_80_day_sla_tab_with_all_results
    expect(assessor_sla_index_page.eighty_day_sla_tab["class"]).to include(
      "govuk-tabs__list-item--selected",
    )
    expect(assessor_sla_index_page.ten_day_sla_tab["class"]).not_to include(
      "govuk-tabs__list-item--selected",
    )
    expect(assessor_sla_index_page.forty_day_sla_tab["class"]).not_to include(
      "govuk-tabs__list-item--selected",
    )
    expect(assessor_sla_index_page).to have_content(eighty_day_sla_uk.reference)
    expect(assessor_sla_index_page).to have_content(eighty_day_sla_eu.reference)
    expect(assessor_sla_index_page).to have_content(
      eighty_day_sla_efta.reference,
    )
    expect(assessor_sla_index_page).to have_content(
      eighty_day_sla_rest_of_world.reference,
    )
  end

  def when_filter_by_nearing_breach_status
    assessor_sla_index_page.breach_status_filter.items.first.click
    assessor_sla_index_page.apply_filters.click
  end

  def when_i_clear_filters
    assessor_sla_index_page.clear_filters.click
  end

  def then_i_see_list_of_only_ten_day_nearing_breach_applications
    expect(assessor_sla_index_page).to have_content(ten_day_sla_uk.reference)
    expect(assessor_sla_index_page).to have_content(ten_day_sla_eu.reference)
    expect(assessor_sla_index_page).not_to have_content(
      ten_day_sla_efta.reference,
    )
    expect(assessor_sla_index_page).not_to have_content(
      ten_day_sla_rest_of_world.reference,
    )
  end

  def then_i_see_list_of_only_forty_day_nearing_breach_applications
    expect(assessor_sla_index_page).to have_content(forty_day_sla_uk.reference)
    expect(assessor_sla_index_page).to have_content(forty_day_sla_eu.reference)
    expect(assessor_sla_index_page).not_to have_content(
      forty_day_sla_efta.reference,
    )
    expect(assessor_sla_index_page).not_to have_content(
      forty_day_sla_rest_of_world.reference,
    )
  end

  def then_i_see_list_of_only_eighty_day_nearing_breach_applications
    expect(assessor_sla_index_page).to have_content(eighty_day_sla_uk.reference)
    expect(assessor_sla_index_page).to have_content(eighty_day_sla_eu.reference)
    expect(assessor_sla_index_page).not_to have_content(
      eighty_day_sla_efta.reference,
    )
    expect(assessor_sla_index_page).not_to have_content(
      eighty_day_sla_rest_of_world.reference,
    )
  end

  def when_i_go_to_view_totals_page
    assessor_sla_index_page.click_on "Totals"
  end

  def when_i_go_to_applications_page
    assessor_sla_index_page.click_on "Applications"
  end
end
