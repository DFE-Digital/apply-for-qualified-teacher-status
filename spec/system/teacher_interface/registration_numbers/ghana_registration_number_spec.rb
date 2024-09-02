# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher Ghana registration number", type: :system do
  before do
    given_i_am_authorized_as_a_user(teacher)
    given_an_application_form_exists
  end

  it "records" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_registration_number_task

    when_i_click_the_registration_number_task
    then_i_see_the(:teacher_ghana_registration_number_page)

    when_i_fill_in_the_registration_number
    then_i_see_the(:teacher_application_page)
    and_i_see_the_completed_registration_number_task
  end

  context "when the registration number fails validation" do
    it "does not record" do
      when_i_visit_the(:teacher_application_page)
      then_i_see_the(:teacher_application_page)
      and_i_see_the_registration_number_task

      when_i_click_the_registration_number_task
      then_i_see_the(:teacher_ghana_registration_number_page)

      when_i_fill_in_the_registration_number_incorrectly
      then_i_see_the(:teacher_ghana_registration_number_page)
      and_i_see_the_validation_failures
    end
  end

  private

  def given_an_application_form_exists
    application_form
  end

  def and_i_see_the_registration_number_task
    expect(teacher_application_page.ghana_registration_number_task_item).not_to be_nil
  end

  def when_i_click_the_registration_number_task
    teacher_application_page.ghana_registration_number_task_item.click
  end

  def when_i_fill_in_the_registration_number
    teacher_ghana_registration_number_page.form.license_number_part_one_field.fill_in with:
      "PT"
    teacher_ghana_registration_number_page.form.license_number_part_two_field.fill_in with:
      "123456"
    teacher_ghana_registration_number_page.form.license_number_part_three_field.fill_in with:
      "1234"
    teacher_ghana_registration_number_page.form.continue_button.click
  end

  def when_i_fill_in_the_registration_number_incorrectly
    teacher_ghana_registration_number_page.form.license_number_part_one_field.fill_in with:
      "P"
    teacher_ghana_registration_number_page.form.license_number_part_two_field.fill_in with:
      "1"
    teacher_ghana_registration_number_page.form.license_number_part_three_field.fill_in with:
      "1"
    teacher_ghana_registration_number_page.form.continue_button.click
  end

  def and_i_see_the_completed_registration_number_task
    expect(
      teacher_application_page.ghana_registration_number_task_item.status_tag.text,
    ).to eq("Completed")
  end

  def and_i_see_the_validation_failures
    expect(
      teacher_ghana_registration_number_page.form.license_number_error_message.text,
    ).to include(
      "Enter your teacher license number. " \
      "It is made up of 2 letters, 6 numbers and a final 4 numbers. " \
      "For example, PT/123456/1234."
    )
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def application_form
    @application_form ||=
      create(:application_form, teacher:, region: ghana_country.regions.first, needs_registration_number: true)
  end

  def ghana_country
    @ghana_country ||= create(:country, :with_national_region, code: "GH")
  end
end
