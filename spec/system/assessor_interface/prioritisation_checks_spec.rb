# frozen_string_literal: true
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor prioritisation checks", type: :system do
  before do
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_prioritisation_checks_pending
  end

  it "accepts work history checks and goes for prioritisation references" do
    when_i_visit_the(:assessor_application_page, reference:)
    then_i_see_the(:assessor_application_page, reference:)

    when_i_click_on_prioritisation_work_history_checks
    then_i_see_the(
      :assessor_prioritisation_work_history_checks_page,
      reference:,
      assessment_id:,
    )

    assessment
      .prioritisation_work_history_checks
      .each do |prioritisation_work_history_check|
      when_i_select_prioritisation_work_history_to_check(
        prioritisation_work_history_check,
      )
      then_i_see_the(
        :assessor_prioritisation_work_history_check_page,
        reference:,
        assessment_id:,
        prioritisation_work_history_check_id:
          prioritisation_work_history_check.id,
      )

      when_i_submit_yes_on_the_work_history_check_form
      then_i_see_the(
        :assessor_prioritisation_work_history_checks_page,
        reference:,
        assessment_id:,
      )
      and_i_see_the_prioritisation_work_history_check_as_accepted(
        prioritisation_work_history_check,
      )
    end

    when_i_click_on_back_to_overview
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_prioritisation_work_history_checks_task_as_completed
    and_i_see_prioritisation_reference_task_as_not_started

    when_i_click_on_prioritisation_reference_checks
    then_i_see_the(
      :new_assessor_prioritisation_references_page,
      reference:,
      assessment_id:,
    )
    and_i_see_content_about_all_schools

    when_i_click_on_submit_on_the_new_references_form
    then_i_see_the(
      :confirmation_assessor_prioritisation_references_page,
      reference:,
      assessment_id:,
    )

    when_i_click_on_see_application_overview
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_prioritisation_reference_task_as_waiting_on
  end

  it "rejects all work history check and deprioritises" do
    when_i_visit_the(:assessor_application_page, reference:)
    then_i_see_the(:assessor_application_page, reference:)

    when_i_click_on_prioritisation_work_history_checks
    then_i_see_the(
      :assessor_prioritisation_work_history_checks_page,
      reference:,
      assessment_id:,
    )

    assessment
      .prioritisation_work_history_checks
      .each do |prioritisation_work_history_check|
      when_i_select_prioritisation_work_history_to_check(
        prioritisation_work_history_check,
      )
      then_i_see_the(
        :assessor_prioritisation_work_history_check_page,
        reference:,
        assessment_id:,
        prioritisation_work_history_check_id:
          prioritisation_work_history_check.id,
      )

      when_i_submit_no_on_the_work_history_check_form
      then_i_see_the(
        :assessor_prioritisation_work_history_checks_page,
        reference:,
        assessment_id:,
      )
      and_i_see_the_prioritisation_work_history_check_as_rejected(
        prioritisation_work_history_check,
      )
    end

    when_i_click_on_back_to_overview
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_prioritisation_work_history_checks_task_as_completed
    and_i_see_prioritisation_decision_task_as_not_started

    when_i_click_on_prioritisation_decision
    then_i_see_the(
      :assessor_prioritisation_decision_page,
      reference:,
      assessment_id:,
    )
    and_i_see_content_for_application_being_deprioritised
  end

  context "when the assessment has received prioritisation reference requests" do
    before do
      assessment.prioritisation_work_history_checks.update_all(passed: true)

      create(
        :received_prioritisation_reference_request,
        assessment:,
        prioritisation_work_history_check:
          assessment.prioritisation_work_history_checks.first,
      )
      create(
        :received_prioritisation_reference_request,
        assessment:,
        prioritisation_work_history_check:
          assessment.prioritisation_work_history_checks.last,
      )
    end

    it "accepts reference requests and prioritises" do
      when_i_visit_the(:assessor_application_page, reference:)
      then_i_see_the(:assessor_application_page, reference:)
      and_i_see_prioritisation_work_history_checks_task_as_completed
      and_i_see_prioritisation_reference_task_as_received

      when_i_click_on_prioritisation_reference_checks
      then_i_see_the(
        :assessor_prioritisation_references_page,
        reference:,
        assessment_id:,
      )
      when_i_select_prioritisation_reference_to_review(
        assessment.prioritisation_reference_requests.first,
      )
      then_i_see_the(
        :review_assessor_prioritisation_reference_page,
        reference:,
        assessment_id:,
        prioritisation_reference_request_id:
          assessment.prioritisation_reference_requests.first.id,
      )

      when_i_submit_yes_on_the_prioritisation_reference_review_form
      then_i_see_the(:assessor_application_page, reference:)
      and_i_see_prioritisation_reference_task_as_completed
      and_i_see_prioritisation_decision_task_as_not_started

      when_i_click_on_prioritisation_decision
      then_i_see_the(
        :assessor_prioritisation_decision_page,
        reference:,
        assessment_id:,
      )
      and_i_see_content_for_application_being_prioritised

      when_i_confirm_prioritisation
      then_i_see_content_for_confirming_application_prioritised

      when_i_click_on_see_application_overview
      then_i_see_the(:assessor_application_page, reference:)
      and_i_see_prioritisation_decision_task_as_completed
      and_i_see_a_flag_for_application_prioritised
    end

    it "rejects reference requests and deprioritises" do
      when_i_visit_the(:assessor_application_page, reference:)
      then_i_see_the(:assessor_application_page, reference:)
      and_i_see_prioritisation_work_history_checks_task_as_completed
      and_i_see_prioritisation_reference_task_as_received

      when_i_click_on_prioritisation_reference_checks
      then_i_see_the(
        :assessor_prioritisation_references_page,
        reference:,
        assessment_id:,
      )

      assessment
        .prioritisation_reference_requests
        .each do |prioritisation_reference_request|
        when_i_select_prioritisation_reference_to_review(
          prioritisation_reference_request,
        )
        then_i_see_the(
          :review_assessor_prioritisation_reference_page,
          reference:,
          assessment_id:,
          prioritisation_reference_request_id:
            prioritisation_reference_request.id,
        )

        when_i_submit_no_on_the_prioritisation_reference_review_form
        then_i_see_the(
          :assessor_prioritisation_references_page,
          reference:,
          assessment_id:,
        )
        and_i_see_the_prioritisation_reference_as_rejected(
          prioritisation_reference_request,
        )
      end

      when_i_click_on_back_to_overview
      then_i_see_the(:assessor_application_page, reference:)
      and_i_see_prioritisation_reference_task_as_completed
      and_i_see_prioritisation_decision_task_as_not_started

      when_i_click_on_prioritisation_decision
      then_i_see_the(
        :assessor_prioritisation_decision_page,
        reference:,
        assessment_id:,
      )
      and_i_see_content_for_application_being_deprioritised
    end
  end

  private

  def given_there_is_an_application_form_with_prioritisation_checks_pending
    application_form
  end

  def when_i_click_on_prioritisation_work_history_checks
    assessor_application_page.prioritisation_work_history_check_task.click
  end

  def when_i_click_on_prioritisation_reference_checks
    assessor_application_page.prioritisation_reference_check_task.click
  end

  def when_i_click_on_prioritisation_decision
    assessor_application_page.prioritisation_decision_task.click
  end

  def when_i_select_prioritisation_work_history_to_check(
    prioritisation_work_history_check
  )
    assessor_prioritisation_work_history_checks_page.click_on prioritisation_work_history_check.work_history.school_name
  end

  def when_i_submit_yes_on_the_work_history_check_form
    assessor_prioritisation_work_history_check_page.submit_yes
  end

  def when_i_submit_no_on_the_work_history_check_form
    assessor_prioritisation_work_history_check_page.submit_no
  end

  def and_i_see_the_prioritisation_work_history_check_as_accepted(
    prioritisation_work_history_check
  )
    item =
      assessor_prioritisation_work_history_checks_page.task_list.find_item(
        prioritisation_work_history_check.work_history.school_name,
      )
    expect(item.status_tag.text).to eq("Accepted")
  end

  def and_i_see_the_prioritisation_work_history_check_as_rejected(
    prioritisation_work_history_check
  )
    item =
      assessor_prioritisation_work_history_checks_page.task_list.find_item(
        prioritisation_work_history_check.work_history.school_name,
      )
    expect(item.status_tag.text).to eq("Rejected")
  end

  def and_i_see_the_prioritisation_reference_as_rejected(
    prioritisation_reference_request
  )
    item =
      assessor_prioritisation_references_page.task_list.find_item(
        prioritisation_reference_request.work_history.school_name,
      )
    expect(item.status_tag.text).to eq("Rejected")
  end

  def when_i_click_on_back_to_overview
    click_on "Back to overview"
  end

  def and_i_see_prioritisation_work_history_checks_task_as_completed
    expect(
      assessor_application_page
        .prioritisation_work_history_check_task
        .status_tag
        .text,
    ).to eq("Completed")
  end

  def and_i_see_prioritisation_reference_task_as_not_started
    expect(
      assessor_application_page
        .prioritisation_reference_check_task
        .status_tag
        .text,
    ).to eq("Not started")
  end

  def and_i_see_prioritisation_reference_task_as_received
    expect(
      assessor_application_page
        .prioritisation_reference_check_task
        .status_tag
        .text,
    ).to eq("Received")
  end

  def and_i_see_prioritisation_reference_task_as_completed
    expect(
      assessor_application_page
        .prioritisation_reference_check_task
        .status_tag
        .text,
    ).to eq("Completed")
  end

  def and_i_see_prioritisation_reference_task_as_waiting_on
    expect(
      assessor_application_page
        .prioritisation_reference_check_task
        .status_tag
        .text,
    ).to eq("Waiting on")
  end

  def and_i_see_prioritisation_decision_task_as_not_started
    expect(
      assessor_application_page.prioritisation_decision_task.status_tag.text,
    ).to eq("Not started")
  end

  def and_i_see_prioritisation_decision_task_as_completed
    expect(
      assessor_application_page.prioritisation_decision_task.status_tag.text,
    ).to eq("Completed")
  end

  def and_i_see_content_about_all_schools
    assessment
      .prioritisation_work_history_checks
      .each do |prioritisation_work_history_check|
      expect(new_assessor_prioritisation_references_page).to have_content(
        prioritisation_work_history_check.work_history.school_name,
      )
    end
  end

  def when_i_click_on_submit_on_the_new_references_form
    new_assessor_prioritisation_references_page.form.submit_button.click
  end

  def when_i_click_on_see_application_overview
    click_on "See application overview"
  end

  def and_i_see_content_for_application_being_deprioritised
    expect(assessor_prioritisation_decision_page).to have_content(
      "You have indicated that this applicant doesn’t have any work history in England " \
        "that meets the criteria for prioritisation",
    )
  end

  def and_i_see_content_for_application_being_prioritised
    expect(assessor_prioritisation_decision_page).to have_content(
      "You have indicated that this applicant has valid work history in England " \
        "to be prioritised and have accepted at least one reference that confirms their work history in England.",
    )
  end

  def when_i_select_prioritisation_reference_to_review(
    prioritisation_reference_request
  )
    assessor_prioritisation_references_page.click_on prioritisation_reference_request.work_history.school_name
  end

  def when_i_submit_yes_on_the_work_history_check_form
    assessor_prioritisation_work_history_check_page.submit_yes
  end

  def when_i_submit_no_on_the_work_history_check_form
    assessor_prioritisation_work_history_check_page.submit_no
  end

  def when_i_submit_yes_on_the_prioritisation_reference_review_form
    review_assessor_prioritisation_reference_page.submit_yes
  end

  def when_i_submit_no_on_the_prioritisation_reference_review_form
    review_assessor_prioritisation_reference_page.submit_no(note: "Note")
  end

  def when_i_confirm_prioritisation
    assessor_prioritisation_decision_page.submit_yes
  end

  def then_i_see_content_for_confirming_application_prioritised
    expect(page).to have_content(
      "QTS application #{application_form.reference} will be prioritised",
    )
  end

  def and_i_see_a_flag_for_application_prioritised
    expect(page).to have_content("Prioritised")
  end

  def application_form
    @application_form ||=
      create(:application_form, :submitted).tap do |application_form|
        assessment = create(:assessment, application_form:)
        create(
          :prioritisation_work_history_check,
          assessment:,
          work_history:
            create(
              :work_history,
              :completed,
              school_name: "School 1",
              application_form:,
            ),
        )
        create(
          :prioritisation_work_history_check,
          assessment:,
          work_history:
            create(
              :work_history,
              :completed,
              school_name: "School 2",
              application_form:,
            ),
        )
      end
  end

  delegate :reference, :assessment, to: :application_form

  def assessment_id
    assessment.id
  end
end
