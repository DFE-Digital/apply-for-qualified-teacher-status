# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher prioritisation reference", type: :system do
  before { given_there_is_a_prioritisation_reference_request }

  it "allows filling yes to all answers in the reference" do
    when_i_visit_the(:teacher_prioritisation_reference_requested_page, slug:)
    then_i_see_the(:teacher_prioritisation_reference_requested_page, slug:)
    and_i_see_the_work_history_details

    when_i_click_start_now
    then_i_see_the(
      :teacher_edit_prioritisation_reference_request_contact_page,
      slug:,
    )

    when_i_choose_yes_for_contact
    then_i_see_the(
      :teacher_edit_prioritisation_reference_request_confirm_applicant_page,
      slug:,
    )

    when_i_choose_yes_for_confirm_applicant
    then_i_see_the(
      :teacher_check_prioritisation_reference_request_answers_page,
      slug:,
    )
    and_i_see_the_answers_for_yes

    when_i_submit_the_response
    then_i_see_the(:teacher_prioritisation_reference_received_page, slug:)
    and_i_see_the_confirmation_panel
  end

  it "allows filling no to all answers in the reference" do
    when_i_visit_the(:teacher_prioritisation_reference_requested_page, slug:)
    then_i_see_the(:teacher_prioritisation_reference_requested_page, slug:)
    and_i_see_the_work_history_details

    when_i_click_start_now
    then_i_see_the(
      :teacher_edit_prioritisation_reference_request_contact_page,
      slug:,
    )

    when_i_choose_no_for_contact_with_comment
    then_i_see_the(
      :teacher_edit_prioritisation_reference_request_confirm_applicant_page,
      slug:,
    )

    when_i_choose_no_for_confirm_applicant_with_comment
    then_i_see_the(
      :teacher_check_prioritisation_reference_request_answers_page,
      slug:,
    )
    and_i_see_the_answers_for_no

    when_i_submit_the_response
    then_i_see_the(:teacher_prioritisation_reference_received_page, slug:)
    and_i_see_the_confirmation_panel
  end

  context "when the prioritisation request has already been received" do
    before do
      prioritisation_reference_request.update!(
        contact_response: true,
        confirm_applicant_response: true,
      )
      prioritisation_reference_request.received!
    end

    it "lets the referee know that the reference has been submitted" do
      when_i_visit_the(:teacher_prioritisation_reference_requested_page, slug:)
      then_i_see_the(:teacher_prioritisation_reference_received_page, slug:)
      and_i_see_the_confirmation_panel
    end
  end

  context "when the prioritisation request is not found" do
    it "lets the referee know that the reference is no longer required" do
      when_i_visit_the(
        :teacher_prioritisation_reference_requested_page,
        slug: "INVALID",
      )
      then_i_see_not_found_page
    end
  end

  context "when the prioritisation has already been made" do
    before do
      prioritisation_reference_request.assessment.update!(
        prioritisation_decision_at: Time.current,
        prioritised: true,
      )
    end

    it "lets the referee know that the reference is no longer required" do
      when_i_visit_the(:teacher_prioritisation_reference_requested_page, slug:)
      then_i_see_not_found_page
    end
  end

  def given_there_is_a_prioritisation_reference_request
    prioritisation_reference_request
  end

  def and_i_see_the_work_history_details
    expect(
      teacher_prioritisation_reference_requested_page.work_history_details.text,
    ).to eq("School from January 2020 to January 2023")
  end

  def when_i_click_start_now
    teacher_prioritisation_reference_requested_page.start_button.click
  end

  def when_i_choose_yes_for_contact
    teacher_edit_prioritisation_reference_request_contact_page.submit_yes
  end

  def when_i_choose_yes_for_confirm_applicant
    teacher_edit_prioritisation_reference_request_confirm_applicant_page.submit_yes
  end

  def when_i_choose_no_for_contact_with_comment
    teacher_edit_prioritisation_reference_request_contact_page
      .form
      .radio_items
      .second
      .choose

    fill_in "Provide a reason", with: "Comments"

    teacher_edit_prioritisation_reference_request_contact_page
      .form
      .continue_button
      .click
  end

  def when_i_choose_no_for_confirm_applicant_with_comment
    teacher_edit_prioritisation_reference_request_confirm_applicant_page
      .form
      .radio_items
      .second
      .choose

    fill_in "Provide a reason", with: "Comments"

    teacher_edit_prioritisation_reference_request_confirm_applicant_page
      .form
      .continue_button
      .click
  end

  def and_i_see_the_answers_for_yes
    summary_list =
      teacher_check_prioritisation_reference_request_answers_page.summary_list

    expect(summary_list).to be_visible

    expect(summary_list.rows[0].key.text).to eq("Your full name")
    expect(summary_list.rows[0].value.text).to eq("John Smith")

    expect(summary_list.rows[1].key.text).to eq("Your job title")
    expect(summary_list.rows[1].value.text).to eq("Headteacher")

    expect(summary_list.rows[2].key.text).to eq("Where you work")
    expect(summary_list.rows[2].value.text).to eq("School")

    expect(summary_list.rows[3].key.text).to eq("Are these details correct?")
    expect(summary_list.rows[3].value.text).to eq("Yes")

    expect(summary_list.rows[4].key.text).to eq(
      "Can you confirm the applicant’s work history?",
    )
    expect(summary_list.rows[4].value.text).to eq("Yes")
  end

  def and_i_see_the_answers_for_no
    summary_list =
      teacher_check_prioritisation_reference_request_answers_page.summary_list

    expect(summary_list).to be_visible

    expect(summary_list.rows[0].key.text).to eq("Your full name")
    expect(summary_list.rows[0].value.text).to eq("John Smith")

    expect(summary_list.rows[1].key.text).to eq("Your job title")
    expect(summary_list.rows[1].value.text).to eq("Headteacher")

    expect(summary_list.rows[2].key.text).to eq("Where you work")
    expect(summary_list.rows[2].value.text).to eq("School")

    expect(summary_list.rows[3].key.text).to eq("Are these details correct?")
    expect(summary_list.rows[3].value.text).to eq("No")

    expect(summary_list.rows[4].key.text).to eq("Provide a reason")
    expect(summary_list.rows[4].value.text).to eq("Comments")

    expect(summary_list.rows[5].key.text).to eq(
      "Can you confirm the applicant’s work history?",
    )
    expect(summary_list.rows[5].value.text).to eq("No")

    expect(summary_list.rows[6].key.text).to eq("Provide a reason")
    expect(summary_list.rows[6].value.text).to eq("Comments")
  end

  def when_i_submit_the_response
    teacher_check_prioritisation_reference_request_answers_page.submit_button.click
  end

  def and_i_see_the_confirmation_panel
    expect(
      teacher_prioritisation_reference_received_page.confirmation_panel,
    ).to be_visible
  end

  def then_i_see_not_found_page
    expect(teacher_prioritisation_reference_requested_page).to have_content(
      "We no longer need you to act as a reference",
    )
  end

  def prioritisation_reference_request
    @prioritisation_reference_request ||=
      create(
        :prioritisation_reference_request,
        :requested,
        work_history:
          create(
            :work_history,
            :completed,
            contact_job: "Headteacher",
            contact_name: "John Smith",
            end_date: Date.new(2023, 1, 1),
            hours_per_week: 30,
            school_name: "School",
            start_date: Date.new(2020, 1, 1),
          ),
      )
  end

  delegate :slug, to: :prioritisation_reference_request
end
