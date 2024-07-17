# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor suitability", type: :system do
  before { given_suitability_is_enabled }
  after { given_suitability_is_disabled }

  it "view suitability records" do
    given_i_am_authorized_as_a_user(assessor)
    given_a_record_exists

    when_i_visit_the(:assessor_suitability_records_page)
    then_i_see_the_suitability_records
  end

  it "create suitability records" do
    given_i_am_authorized_as_a_user(assessor)

    when_i_visit_the(:assessor_suitability_records_page)
    and_i_click_the_add_new_entry_button
    then_i_see_the(:assessor_create_suitability_record_page)

    when_i_fill_in_the_fields
    and_i_submit_the_form
    then_i_see_the_suitability_records
  end

  def given_suitability_is_enabled
    FeatureFlags::FeatureFlag.deactivate(:suitability)
  end

  def given_suitability_is_disabled
    FeatureFlags::FeatureFlag.deactivate(:suitability)
  end

  def given_a_record_exists
    suitability_record = create(:suitability_record)
    create(:suitability_record_name, suitability_record:, value: "John Smith")
  end

  def then_i_see_the_suitability_records
    expect(assessor_suitability_records_page.heading).to be_visible
    expect(assessor_suitability_records_page.records.size).to eq(1)
    expect(assessor_suitability_records_page.records.first.heading.text).to eq(
      "John Smith",
    )
  end

  def and_i_click_the_add_new_entry_button
    assessor_suitability_records_page.add_new_entry_button.click
  end

  def when_i_fill_in_the_fields
    form = assessor_create_suitability_record_page.form

    form.name_field.fill_in with: "John Smith"
    form.alias_field.fill_in with: "Alias"
    form.location_field.fill_in with: "France"
    form.date_of_birth_day_field.fill_in with: "1"
    form.date_of_birth_month_field.fill_in with: "1"
    form.date_of_birth_year_field.fill_in with: "1999"
    form.email_field.fill_in with: "test@example.com"
    form.note_field.fill_in with: "Some note"
  end

  def and_i_submit_the_form
    assessor_create_suitability_record_page.form.submit_button.click
  end

  def assessor
    @assessor ||= create(:staff, :with_assess_permission)
  end
end
