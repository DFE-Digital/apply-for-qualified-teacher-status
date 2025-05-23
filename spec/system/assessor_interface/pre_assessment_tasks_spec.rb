# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor pre-assessment tasks", type: :system do
  before do
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_professional_standing_request
  end

  it "passes preliminary check and locate professional standing" do
    when_i_visit_the(:assessor_application_page, reference:)
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_a_preliminary_check_status
    and_i_see_an_unstarted_preliminary_check_task

    when_i_click_on_the_preliminary_check_task
    and_i_choose_yes_to_both_questions
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_a_completed_preliminary_check_task
    and_the_teacher_receives_a_request_your_lops_email
    and_the_assessor_is_unassigned

    when_i_visit_the(:assessor_application_page, reference:)
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_a_waiting_on_status
    and_i_click_awaiting_professional_standing
    then_i_see_the(
      :assessor_locate_professional_standing_request_page,
      reference:,
    )

    when_i_fill_in_the_locate_form
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_a_assessment_not_started_status
    and_the_teacher_receives_a_professional_standing_received_email
  end

  it "fails preliminary check" do
    when_i_visit_the(:assessor_application_page, reference:)
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_a_preliminary_check_status
    and_i_see_an_unstarted_preliminary_check_task

    when_i_click_on_the_preliminary_check_task
    and_i_choose_no_to_both_questions
    then_i_see_the(:assessor_complete_assessment_page, reference:)

    when_i_select_decline_qts
    then_i_see_the(
      :assessor_declare_assessment_recommendation_page,
      reference:,
      recommendation: "decline",
    )
    and_i_see_the_failure_reasons
  end

  private

  def given_there_is_an_application_form_with_professional_standing_request
    application_form
  end

  def and_i_see_a_waiting_on_status
    expect(assessor_application_page.status_summary.value).to have_text(
      "Waiting on LoPS",
    )
  end

  def and_i_see_a_preliminary_check_status
    expect(assessor_application_page.status_summary.value).to have_text(
      "Preliminary check",
    )
  end

  def and_i_see_a_assessment_not_started_status
    expect(assessor_application_page.status_summary.value).to have_text(
      "Assessment not started",
    )
  end

  def and_i_see_an_unstarted_preliminary_check_task
    expect(assessor_application_page.task_lists.first).to have_content(
      "Preliminary check (qualifications)",
    )
    expect(assessor_application_page.preliminary_check_task).to have_content(
      "Not started",
    )
    expect(
      assessor_application_page.awaiting_professional_standing_task,
    ).to have_content("Cannot start")
  end

  def when_i_click_on_the_preliminary_check_task
    assessor_application_page.preliminary_check_task.click
  end

  def and_i_choose_yes_to_both_questions
    assessor_assessment_section_page.preliminary_form.radios.each do |radio|
      radio.items.first.choose
    end

    assessor_assessment_section_page.preliminary_form.continue_button.click
  end

  def and_i_choose_no_to_both_questions
    assessor_assessment_section_page.preliminary_form.radios.each do |radio|
      radio.items.second.choose
    end

    assessor_assessment_section_page.preliminary_form.continue_button.click
  end

  def when_i_select_decline_qts
    expect(assessor_complete_assessment_page.new_states.count).to eq(1)
    assessor_complete_assessment_page.decline_qts.input.choose
    assessor_complete_assessment_page.continue_button.click
  end

  def and_i_see_the_failure_reasons
    failure_reason_items =
      assessor_declare_assessment_recommendation_page
        .failure_reason_lists
        .first
        .items

    expect(failure_reason_items.first.text).to eq(
      "The teaching qualifications do not meet the required academic level (level 6).",
    )

    expect(failure_reason_items.second.text).to start_with(
      "The applicant is not qualified to teach one of the subjects that we currently accept",
    )
  end

  def and_i_see_a_completed_preliminary_check_task
    expect(assessor_application_page.preliminary_check_task).to have_content(
      "Completed",
    )
    expect(
      assessor_application_page.awaiting_professional_standing_task,
    ).to have_content("Waiting on")
  end

  def and_the_teacher_receives_a_request_your_lops_email
    expect(TeacherMailer.deliveries.count).to eq(1)
    expect(TeacherMailer.deliveries.first.subject).to eq(
      "Your QTS application: Request your Letter of Professional Standing",
    )
  end

  def and_the_assessor_is_unassigned
    expect(application_form.reload.assessor).to be_nil
  end

  def and_i_click_awaiting_professional_standing
    assessor_application_page.awaiting_professional_standing_task.click
  end

  def when_i_fill_in_the_locate_form
    form = assessor_locate_professional_standing_request_page.form

    form.received_checkbox.click
    form.note_textarea.fill_in with: "Note."
    form.submit_button.click
  end

  def and_the_teacher_receives_a_professional_standing_received_email
    expect(TeacherMailer.deliveries.count).to eq(2)
    expect(TeacherMailer.deliveries.second.subject).to eq(
      I18n.t(
        "mailer.teacher.professional_standing_received.subject",
        certificate: "Letter of Professional Standing",
      ),
    )
  end

  def application_form
    @application_form ||=
      begin
        application_form =
          create(
            :application_form,
            :preliminary_check,
            :with_personal_information,
            :with_teaching_qualification,
            assessor: Staff.last,
            teaching_authority_provides_written_statement: true,
          )
        create(
          :assessment,
          :with_preliminary_qualifications_section,
          :with_professional_standing_request,
          application_form:,
        )
        application_form.region.update!(
          requires_preliminary_check: true,
          teaching_authority_provides_written_statement: true,
        )
        application_form
      end
  end

  delegate :reference, to: :application_form
end
