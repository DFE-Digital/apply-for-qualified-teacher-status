# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher submitting", type: :system do
  let(:application_form) do
    create(
      :application_form,
      :with_personal_information,
      :with_identification_document,
      :with_teaching_qualification,
      :with_age_range,
      :with_subjects,
      :with_english_language_provider,
      :with_work_history,
      :with_written_statement,
      :with_registration_number,
      teacher:,
    )
  end

  before do
    given_i_am_authorized_as_a_user(teacher)
    given_there_is_an_application_form
  end

  it "submits" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)

    when_i_click_check_your_answers
    then_i_see_the(:teacher_check_your_answers_page)

    when_i_confirm_i_have_no_sanctions
    then_i_see_the(:teacher_submitted_application_page)
    and_i_see_the_submitted_application_information
    and_i_receive_an_application_email
  end

  context "when from country requiring written statement from teaching authority" do
    let(:application_form) do
      create(
        :application_form,
        :teaching_authority_provides_written_statement,
        :with_personal_information,
        :with_identification_document,
        :with_teaching_qualification,
        :with_age_range,
        :with_subjects,
        :with_english_language_provider,
        :with_work_history,
        :with_written_statement,
        :with_registration_number,
        teacher:,
      )
    end

    it "submits" do
      when_i_visit_the(:teacher_application_page)
      then_i_see_the(:teacher_application_page)

      when_i_click_check_your_answers
      then_i_see_the(:teacher_check_your_answers_page)

      when_i_confirm_i_have_no_sanctions
      then_i_see_the(:teacher_submitted_application_page)
      and_i_see_the_submitted_application_information_with_lops_pending
      and_i_receive_an_application_email_to_request_lops
    end
  end

  context "when from country requiring written statement from teaching authority and preliminary check" do
    let(:application_form) do
      create(
        :application_form,
        :teaching_authority_provides_written_statement,
        :requires_preliminary_check,
        :with_personal_information,
        :with_identification_document,
        :with_teaching_qualification,
        :with_age_range,
        :with_subjects,
        :with_english_language_provider,
        :with_work_history,
        :with_written_statement,
        :with_registration_number,
        teacher:,
      )
    end

    before do
      application_form.region.update(
        teaching_authority_provides_written_statement: true,
        requires_preliminary_check: true,
      )
    end

    it "submits" do
      when_i_visit_the(:teacher_application_page)
      then_i_see_the(:teacher_application_page)

      when_i_click_check_your_answers
      then_i_see_the(:teacher_check_your_answers_page)
      and_i_see_the_identity_document_summary

      when_i_confirm_i_have_no_sanctions
      then_i_see_the(:teacher_submitted_application_page)
      and_i_see_the_submitted_application_information_with_preliminary_check_pending
      and_i_receive_an_application_email_for_initial_checks_required
    end
  end

  context "when the application required passport as a form of identity proof" do
    let(:application_form) do
      create(
        :application_form,
        :with_personal_information,
        :with_passport_document,
        :with_teaching_qualification,
        :with_age_range,
        :with_subjects,
        :with_english_language_provider,
        :with_work_history,
        :with_written_statement,
        :with_registration_number,
        teacher:,
      )
    end

    it "submits" do
      when_i_visit_the(:teacher_application_page)
      then_i_see_the(:teacher_application_page)

      when_i_click_check_your_answers
      then_i_see_the(:teacher_check_your_answers_page)
      and_i_see_the_passport_document_summary

      when_i_confirm_i_have_no_sanctions
      then_i_see_the(:teacher_submitted_application_page)
      and_i_see_the_submitted_application_information
      and_i_receive_an_application_email
    end

    context "and the passport has expired" do
      let(:application_form) do
        create(
          :application_form,
          :with_personal_information,
          :with_passport_document,
          :with_teaching_qualification,
          :with_age_range,
          :with_subjects,
          :with_english_language_provider,
          :with_work_history,
          :with_written_statement,
          :with_registration_number,
          teacher:,
          passport_expiry_date: 2.days.ago.to_date,
        )
      end

      it "redirects back to application task list with passport in progress" do
        when_i_visit_the(:teacher_application_page)
        then_i_see_the(:teacher_application_page)
        and_i_see_the_completed_passport_document_task

        when_i_click_check_your_answers
        then_i_see_the(:teacher_application_page)
        and_i_see_the_in_progress_passport_document_task
        and_i_see_content_that_my_passport_has_expired
      end
    end
  end

  context "when application has other England work history" do
    let(:application_form) do
      create(
        :application_form,
        :with_personal_information,
        :with_identification_document,
        :with_teaching_qualification,
        :with_age_range,
        :with_subjects,
        :with_english_language_provider,
        :with_work_history,
        :with_other_england_work_history,
        :with_written_statement,
        :with_registration_number,
        teacher:,
      )
    end

    it "submits" do
      when_i_visit_the(:teacher_application_page)
      then_i_see_the(:teacher_application_page)

      when_i_click_check_your_answers
      then_i_see_the(:teacher_check_your_answers_page)
      and_i_see_the_other_england_work_history_summary

      when_i_confirm_i_have_no_sanctions
      then_i_see_the(:teacher_submitted_application_page)
      and_i_see_the_submitted_application_information
      and_i_receive_an_application_email
    end
  end

  def and_i_see_the_identity_document_summary
    expect(teacher_submitted_application_page).to have_content(
      "Upload your identity document",
    )
    expect(teacher_submitted_application_page).not_to have_content(
      "Upload your passport",
    )
  end

  def and_i_see_the_passport_document_summary
    expect(teacher_submitted_application_page).not_to have_content(
      "Upload your identity document",
    )
    expect(teacher_submitted_application_page).to have_content(
      "Upload your passport",
    )
  end

  def and_i_see_the_other_england_work_history_summary
    expect(teacher_submitted_application_page).to have_content(
      "Other work experience in England",
    )
  end

  def given_there_is_an_application_form
    application_form
  end

  def when_i_click_check_your_answers
    teacher_application_page.check_answers.click
  end

  def when_i_confirm_i_have_no_sanctions
    allow_any_instance_of(UpdateTRSMatchJob).to receive(:perform)

    teacher_check_your_answers_page
      .submission_declaration
      .form
      .confirm_no_sanctions
      .click

    teacher_check_your_answers_page
      .submission_declaration
      .form
      .submit_button
      .click
  end

  def and_i_see_the_submitted_application_information
    expect(teacher_submitted_application_page.panel.heading.text).to eq(
      "Application received",
    )
    expect(teacher_submitted_application_page.panel.body.text).to eq(
      "Your application reference number\n#{application_form.reference}",
    )
  end

  def and_i_see_the_submitted_application_information_with_lops_pending
    expect(teacher_submitted_application_page).to have_content(
      "Application submitted",
    )
    expect(teacher_submitted_application_page).to have_content(
      "Application reference number: #{application_form.reference}",
    )
    expect(teacher_submitted_application_page).to have_content(
      "You must now get your Letter of Professional Standing from the teaching authority.",
    )
  end

  def and_i_see_the_submitted_application_information_with_preliminary_check_pending
    expect(teacher_submitted_application_page).to have_content(
      "Application submitted",
    )
    expect(teacher_submitted_application_page).to have_content(
      "Application reference number: #{application_form.reference}",
    )
    expect(teacher_submitted_application_page).to have_content(
      "We need to carry out some initial checks on your application. " \
        "We will email you to let you know if your application passes these initial checks.",
    )
  end

  def and_i_receive_an_application_email
    message = ActionMailer::Base.deliveries.last
    expect(message).not_to be_nil

    expect(message.subject).to eq("Your QTS application has been received")
    expect(message.to).to include("teacher@example.com")
  end

  def and_i_receive_an_application_email_to_request_lops
    message = ActionMailer::Base.deliveries.last
    expect(message).not_to be_nil

    expect(message.subject).to eq(
      "Your QTS application: Request your Letter of Professional Standing",
    )
    expect(message.to).to include("teacher@example.com")
  end

  def and_i_receive_an_application_email_for_initial_checks_required
    message = ActionMailer::Base.deliveries.last
    expect(message).not_to be_nil

    expect(message.subject).to eq(
      "Your QTS application: Initial checks required",
    )
    expect(message.to).to include("teacher@example.com")
  end

  def and_i_see_the_completed_passport_document_task
    expect(
      teacher_application_page.passport_document_task_item.status_tag.text,
    ).to eq("Completed")
  end

  def and_i_see_the_in_progress_passport_document_task
    expect(
      teacher_application_page.passport_document_task_item.status_tag.text,
    ).to eq("In progress")
  end

  def and_i_see_content_that_my_passport_has_expired
    expect(teacher_application_page).to have_content(
      "Your passport has expired",
    )
  end

  def teacher
    @teacher ||= create(:teacher, email: "teacher@example.com")
  end
end
