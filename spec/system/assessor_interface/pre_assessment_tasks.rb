# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor pre-assessment tasks", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_professional_standing_request
  end

  it "passes preliminary check" do
    when_i_visit_the(:assessor_application_page, application_id:)
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_a_waiting_on_status
    and_i_see_an_unstarted_preliminary_check_task

    when_i_click_on_the_preliminary_check_task
    and_i_choose_yes_to_both_questions
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_a_completed_preliminary_check_task
    and_an_email_has_been_sent_to_the_teacher
    and_the_assessor_is_unassigned
  end

  it "fails preliminary check" do
    when_i_visit_the(:assessor_application_page, application_id:)
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_a_waiting_on_status
    and_i_see_an_unstarted_preliminary_check_task

    when_i_click_on_the_preliminary_check_task
    and_i_choose_no_to_both_questions
    then_i_see_the(:complete_assessment_page, application_id:)

    when_i_select_decline_qts
    then_i_see_the(
      :declare_assessment_recommendation_page,
      application_id:,
      recommendation: "decline",
    )
    and_i_see_the_failure_reasons
  end

  private

  def given_there_is_an_application_form_with_professional_standing_request
    application_form
  end

  def and_i_see_a_waiting_on_status
    expect(assessor_application_page.overview.status.text).to eq(
      "PRELIMINARY CHECK",
    )
  end

  def and_i_see_an_unstarted_preliminary_check_task
    expect(assessor_application_page.task_list).to have_content(
      "Preliminary check (qualifications)",
    )
    expect(assessor_application_page.preliminary_check_task).to have_content(
      "NOT STARTED",
    )
    expect(
      assessor_application_page.awaiting_professional_standing_task,
    ).to have_content("CANNOT START")
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
    expect(complete_assessment_page.new_states.count).to eq(1)
    complete_assessment_page.decline_qts.input.choose
    complete_assessment_page.continue_button.click
  end

  def and_i_see_the_failure_reasons
    failure_reason_items =
      declare_assessment_recommendation_page.failure_reason_lists.first.items

    expect(failure_reason_items.first.heading.text).to eq(
      "The teaching qualifications do not meet the required academic level (level 6).",
    )

    expect(failure_reason_items.second.heading.text).to eq(
      "The applicant is not qualified to teach one of the subjects we can currently accept.",
    )
  end

  def and_i_see_a_completed_preliminary_check_task
    expect(assessor_application_page.preliminary_check_task).to have_content(
      "COMPLETED",
    )
    expect(
      assessor_application_page.awaiting_professional_standing_task,
    ).to have_content("WAITING ON")
  end

  def and_an_email_has_been_sent_to_the_teacher
    expect(TeacherMailer.deliveries.count).to eq(1)
    expect(TeacherMailer.deliveries.first.subject).to eq(
      I18n.t("mailer.teacher.initial_checks_passed.subject"),
    )
  end

  def and_the_assessor_is_unassigned
    expect(application_form.reload.assessor).to be_nil
  end

  def application_form
    @application_form ||=
      begin
        application_form =
          create(
            :application_form,
            :preliminary_check,
            :with_personal_information,
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

  def application_id
    application_form.id
  end
end
