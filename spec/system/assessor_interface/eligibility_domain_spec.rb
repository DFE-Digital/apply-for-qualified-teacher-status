# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Eligibility email domains", type: :system do
  let(:staff) { create(:staff, :with_assess_permission) }

  it "does not allow any access if user is archived" do
    given_i_am_authorized_as_an_archived_support_user
    given_a_record_exists

    when_i_visit_the(:assessor_eligibility_domains_page)
    then_i_see_the_forbidden_page
  end

  it "create, view, add note, archive and reactivate eligibility records" do
    given_i_am_authorized_as_a_user(staff)

    when_i_visit_the(:assessor_eligibility_domains_page)
    and_i_click_the_add_new_entry_button
    then_i_see_the(:assessor_create_eligibility_domain_page)

    when_i_fill_in_the_fields_and_submit
    then_i_see_the(:assessor_eligibility_domains_page)
    and_i_see_the_eligibility_domains
    and_i_see_the_timeline_event_for_creation

    when_i_click_on_the_eligibility_domain
    then_i_see_the(:assessor_edit_eligibility_domain_page)

    when_i_add_an_update_note
    then_i_see_the(:assessor_eligibility_domains_page)
    and_i_see_the_eligibility_domains
    and_i_see_the_timeline_event_adding_a_note

    when_i_click_on_the_eligibility_domain
    then_i_see_the(:assessor_edit_eligibility_domain_page)

    when_i_click_archive
    then_i_see_the(:assessor_archive_eligibility_domain_page)
    and_i_submit_the_archive_form
    then_i_see_the(:assessor_eligibility_domains_page)
    and_i_see_the_eligibility_domains
    and_i_see_the_timeline_event_archiving_record

    when_i_click_on_the_eligibility_domain
    then_i_see_the(:assessor_edit_eligibility_domain_page)

    when_i_click_reactivate
    then_i_see_the(:assessor_reactivate_eligibility_domain_page)
    and_i_submit_the_reactivate_form
    then_i_see_the(:assessor_eligibility_domains_page)
    and_i_see_the_eligibility_domains
    and_i_see_the_timeline_event_reactivating_record
  end

  def given_a_record_exists
    create(:eligibility_domain)
  end

  def and_i_see_the_eligibility_domains
    expect(assessor_eligibility_domains_page.heading).to be_visible
    expect(assessor_eligibility_domains_page.records.size).to eq(1)
    expect(assessor_eligibility_domains_page.records.first.heading.text).to eq(
      "example.com",
    )
  end

  def and_i_see_the_timeline_event_for_creation
    assessor_eligibility_domains_page
      .records
      .first
      .view_history_details_link
      .click
    expect(
      assessor_eligibility_domains_page.records.first.history_details,
    ).to have_content("New record added").and have_content("Note A")
  end

  def and_i_see_the_timeline_event_adding_a_note
    assessor_eligibility_domains_page
      .records
      .first
      .view_history_details_link
      .click
    expect(
      assessor_eligibility_domains_page.records.first.history_details,
    ).to have_content("Note created").and have_content("Note B")
  end

  def and_i_see_the_timeline_event_archiving_record
    assessor_eligibility_domains_page
      .records
      .first
      .view_history_details_link
      .click
    expect(
      assessor_eligibility_domains_page.records.first.history_details,
    ).to have_content("Record archived").and have_content("Note C")
  end

  def and_i_see_the_timeline_event_reactivating_record
    assessor_eligibility_domains_page
      .records
      .first
      .view_history_details_link
      .click
    expect(
      assessor_eligibility_domains_page.records.first.history_details,
    ).to have_content("Record reactivated").and have_content("Note D")
  end

  def and_i_click_the_add_new_entry_button
    assessor_eligibility_domains_page.add_new_entry_button.click
  end

  def when_i_fill_in_the_fields_and_submit
    form = assessor_create_eligibility_domain_page.form

    form.domain_field.fill_in with: "example.com"
    form.note_field.fill_in with: "Note A"

    form.submit_button.click
  end

  def when_i_add_an_update_note
    form = assessor_edit_eligibility_domain_page.form

    form.note_field.fill_in with: "Note B"

    form.submit_button.click
  end

  def when_i_click_on_the_eligibility_domain
    assessor_eligibility_domains_page.records.first.heading.link.click
  end

  def when_i_click_archive
    click_on "Archive record"
  end

  def when_i_click_reactivate
    click_on "Reactivate record"
  end

  def and_i_submit_the_archive_form
    form = assessor_archive_eligibility_domain_page.form
    form.note_field.fill_in with: "Note C"
    form.submit_button.click
  end

  def and_i_submit_the_reactivate_form
    form = assessor_reactivate_eligibility_domain_page.form
    form.note_field.fill_in with: "Note D"
    form.submit_button.click
  end
end
