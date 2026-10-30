# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher registration number", type: :system do
  before do
    given_i_am_authorized_as_a_user(teacher)
    given_an_application_form_exists
  end

  it "records" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_registration_number_task

    when_i_click_the_registration_number_task
    then_i_see_the(:teacher_registration_number_page)
    and_i_see_the_teacher_reference_number_content

    when_i_fill_in_the_registration_number
    then_i_see_the(:teacher_application_page)
    and_i_see_the_completed_registration_number_task
  end

  private

  def given_an_application_form_exists
    application_form
  end

  def and_i_see_the_registration_number_task
    expect(teacher_application_page.registration_number_task_item).not_to be_nil
  end

  def when_i_click_the_registration_number_task
    teacher_application_page.registration_number_task_item.click
  end

  def and_i_see_the_teacher_reference_number_content
    expect(teacher_registration_number_page.heading).to have_content(
      "What is your teacher reference number?",
    )
    expect(teacher_registration_number_page.hint).to have_content(
      "This may be called a registration or licence number in your country.",
    )
    expect(teacher_registration_number_page.details_summary).to have_content(
      "What to do if you don’t have a teacher reference number",
    )

    teacher_registration_number_page.details_summary.click
    expect(teacher_registration_number_page.details_text).to have_content(
      "If you don’t have a teacher reference number, leave it empty and select " \
        "Continue. We may need to contact you for more information if we cannot " \
        "find you on your country’s online register of teachers.",
    )
  end

  def when_i_fill_in_the_registration_number
    teacher_registration_number_page.form.registration_number_field.fill_in with:
      "abcdef"
    teacher_registration_number_page.form.continue_button.click
  end

  def and_i_see_the_completed_registration_number_task
    expect(
      teacher_application_page.registration_number_task_item.status_tag.text,
    ).to eq("Completed")
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def application_form
    @application_form ||=
      create(:application_form, teacher:, needs_registration_number: true)
  end
end
