# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor viewing draft applications", type: :system do
  let(:region) { create(:region, :in_country, country_code: "FR") }
  let(:draft) do
    create(
      :application_form,
      region:,
      teacher: create(:teacher, email: "draft-applicant@example.com"),
      given_names: "",
      family_name: "",
      created_at: Time.zone.local(2026, 5, 31, 12),
    )
  end
  let(:other_draft) do
    create(
      :application_form,
      region:,
      teacher: create(:teacher, email: "other-draft@example.com"),
      given_names: "Example",
      family_name: "Applicant",
      created_at: 1.day.ago,
    )
  end
  let(:paginated_teacher) do
    create(:teacher, email: "paginated-draft@example.com")
  end
  let(:paginated_drafts) do
    create_list(
      :application_form,
      21,
      region:,
      teacher: paginated_teacher,
      created_at: Time.current,
    )
  end

  around do |example|
    travel_to(Time.zone.local(2026, 11, 24, 12)) { example.run }
  end

  before do
    given_there_are_draft_applications
    given_i_am_authorized_as_a_user(create(:staff))
  end

  it "navigates from submitted applications to the draft list" do
    given_there_is_a_submitted_application
    when_i_visit_the(:assessor_applications_page)
    then_the_submitted_tab_is_active

    when_i_open_the_drafts_tab
    then_i_see_the_draft_list
    and_i_see_the_draft_search
    and_i_see_the_draft_details
    then_i_see_all_draft_applications
  end

  it "finds a draft by email and clears the search" do
    when_i_visit_the(:assessor_draft_applications_page)
    when_i_search_by_email(" DRAFT-APPLICANT@EXAMPLE.COM ")
    then_i_see_the_matching_draft(email: " DRAFT-APPLICANT@EXAMPLE.COM ")

    when_i_clear_the_search
    then_i_see_all_draft_applications
    and_the_search_is_cleared
  end

  it "shows the no-results message and can clear an unmatched search" do
    when_i_visit_the(:assessor_draft_applications_page)
    when_i_search_by_email("missing-draft@example.com")
    then_i_see_no_matching_drafts

    when_i_clear_the_search
    then_i_see_all_draft_applications
  end

  it "shows all drafts for a blank search" do
    when_i_visit_the(:assessor_draft_applications_page)
    when_i_search_by_email("   ")
    then_i_see_all_draft_applications
    and_no_search_is_active
  end

  it "opens the read-only overview and returns to the searched list" do
    when_i_visit_the(:assessor_draft_applications_page)
    when_i_search_by_email(draft.teacher.email)
    when_i_open_the_draft_application
    then_i_see_the_draft_application
    and_i_see_the_read_only_overview

    when_i_click_the_back_link
    then_i_see_the(:assessor_draft_applications_page)
    then_i_see_the_matching_draft
  end

  it "keeps the search and total count across pages" do
    given_there_are_more_than_a_page_of_matching_drafts
    when_i_visit_the(:assessor_draft_applications_page)
    when_i_search_by_email(paginated_teacher.email)
    then_i_see_the_first_page_of_matching_drafts
    and_the_paginated_search_is_retained

    when_i_open_the_next_page
    then_i_see_the_remaining_matching_draft
    and_the_paginated_search_is_retained
  end

  private

  def given_there_are_draft_applications
    draft
    other_draft
  end

  def given_there_is_a_submitted_application
    create(:application_form, :submitted, :with_assessment, region:)
  end

  def given_there_are_more_than_a_page_of_matching_drafts
    paginated_drafts
  end

  def when_i_open_the_drafts_tab
    assessor_applications_page.header.drafts_link.click
  end

  def when_i_search_by_email(email)
    assessor_draft_applications_page.search_for(email)
  end

  def when_i_clear_the_search
    assessor_draft_applications_page.clear_search.click
  end

  def when_i_open_the_draft_application
    assessor_draft_applications_page.search_results.first.email.click
  end

  def when_i_click_the_back_link
    assessor_draft_application_page.back_link.click
  end

  def when_i_open_the_next_page
    assessor_draft_applications_page.pagination.next.click
  end

  def then_the_submitted_tab_is_active
    expect(assessor_applications_page.header).to have_active_submitted_link
  end

  def then_i_see_the_draft_list
    then_i_see_the(:assessor_draft_applications_page)
    expect(
      assessor_draft_applications_page.header,
    ).to have_active_applications_link
    expect(assessor_draft_applications_page.header).to have_active_drafts_link
    expect(assessor_draft_applications_page.heading.text).to eq(
      "Draft Applications",
    )
    expect(assessor_draft_applications_page.title).to start_with(
      "Draft Applications",
    )
  end

  def and_i_see_the_draft_search
    expect(assessor_draft_applications_page.email_label.text).to eq(
      "Find a draft application",
    )
    expect(assessor_draft_applications_page.email_hint.text).to eq(
      "You can search by email address",
    )
  end

  def and_i_see_the_draft_details
    result = assessor_draft_applications_page.search_results.last
    expect(result.email[:href]).to end_with(
      "/assessor/applications/drafts/#{draft.reference}",
    )
    expect(result.summary_keys.map(&:text)).to eq(
      ["Name", "Country trained in", "Draft Started", "Days until deletion"],
    )
    expect(result.summary_values.map(&:text)).to eq(
      ["Not provided", "France", "31 May 2026", "6 days"],
    )
  end

  def then_i_see_all_draft_applications
    expect(result_emails).to eq(
      [other_draft.teacher.email, draft.teacher.email],
    )
  end

  def then_i_see_the_draft_name(name)
    expect(
      assessor_draft_applications_page.search_results.last.summary_value(
        "Name",
      ),
    ).to eq(name)
  end

  def then_i_see_the_matching_draft(email: draft.teacher.email)
    expect(result_emails).to eq([draft.teacher.email])
    expect(assessor_draft_applications_page.result_count.text).to eq(
      "1 result for ‘#{email}’",
    )
    expect(assessor_draft_applications_page.email.value).to eq(email)
  end

  def and_the_search_is_cleared
    expect(assessor_draft_applications_page.email.value).to be_empty
    expect(assessor_draft_applications_page).not_to have_clear_search
  end

  def then_i_see_no_matching_drafts
    expect(assessor_draft_applications_page).to have_empty_state
    expect(assessor_draft_applications_page.result_count.text).to eq(
      "0 results for ‘missing-draft@example.com’",
    )
    expect(assessor_draft_applications_page).to have_no_search_results
  end

  def and_no_search_is_active
    expect(assessor_draft_applications_page).not_to have_clear_search
    expect(assessor_draft_applications_page).not_to have_result_count
  end

  def then_i_see_the_draft_application
    then_i_see_the(:assessor_draft_application_page, reference: draft.reference)
    expect(assessor_draft_application_page.title).to start_with(
      "Draft application",
    )
    expect(assessor_draft_application_page.heading.text).to eq(
      "Draft application",
    )
    expect(
      assessor_draft_application_page.header,
    ).to have_active_applications_link
    expect(assessor_draft_application_page.header).to have_active_drafts_link
  end

  def and_i_see_the_read_only_overview
    expect(assessor_draft_application_page.overview_heading.text).to eq(
      "Overview",
    )
    rows = assessor_draft_application_page.summary_list.rows
    expect(rows.map { |row| row.key.text }).to eq(
      [
        "Name",
        "Country trained in",
        "Email",
        "GOV.UK One Login",
        "Draft created",
        "Days until deletion",
        "Reference",
        "Application history",
      ],
    )
    expect(rows.map { |row| row.value.text }).to eq(
      [
        "Not provided",
        "France",
        draft.teacher.email,
        "Unlinked",
        "31 May 2026",
        "6 days",
        draft.reference,
        "View timeline of this application’s actions",
      ],
    )
    and_i_cannot_change_or_delete_the_draft
  end

  def and_i_cannot_change_or_delete_the_draft
    expect(assessor_draft_application_page).to have_no_change_links
    expect(assessor_draft_application_page).to have_no_delete_controls
  end

  def then_i_see_the_first_page_of_matching_drafts
    expect(assessor_draft_applications_page.search_results.size).to eq(20)
    expect(result_references).to eq(
      paginated_drafts.reverse.first(20).map(&:reference),
    )
  end

  def then_i_see_the_remaining_matching_draft
    expect(result_references).to eq([paginated_drafts.first.reference])
  end

  def and_the_paginated_search_is_retained
    expect(assessor_draft_applications_page.email.value).to eq(
      paginated_teacher.email,
    )
    expect(assessor_draft_applications_page.result_count.text).to eq(
      "21 results for ‘paginated-draft@example.com’",
    )
  end

  def result_emails
    assessor_draft_applications_page.search_results.map do |result|
      result.email.text
    end
  end

  def result_references
    assessor_draft_applications_page.search_results.map do |result|
      result.email[:href].split("/").last
    end
  end
end
