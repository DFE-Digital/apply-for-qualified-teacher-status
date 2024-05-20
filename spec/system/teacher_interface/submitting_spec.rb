# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher submitting", type: :system do
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

  def given_there_is_an_application_form
    application_form
  end

  def when_i_click_check_your_answers
    teacher_application_page.check_answers.click
  end

  def when_i_confirm_i_have_no_sanctions
    allow_any_instance_of(UpdateDQTMatchJob).to receive(:perform)

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
    expect(teacher_submitted_application_page.panel.title.text).to eq(
      "Application complete",
    )
    expect(teacher_submitted_application_page.panel.body.text).to eq(
      "Your application reference number\n#{application_form.reference}",
    )
  end

  def and_i_receive_an_application_email
    message = ActionMailer::Base.deliveries.last
    expect(message).to_not be_nil

    expect(message.subject).to eq(
      "Your QTS application: Awaiting Letter of Professional Standing",
    )
    expect(message.to).to include("teacher@example.com")
  end

  def teacher
    @teacher ||= create(:teacher, email: "teacher@example.com")
  end

  def application_form
    @application_form ||=
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
end
