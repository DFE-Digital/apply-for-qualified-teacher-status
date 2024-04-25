# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher age range and subjects", type: :system do
  before do
    given_i_am_authorized_as_a_user(teacher)
    given_an_application_form_exists
  end

  it "records age range" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_age_range_task

    when_i_click_the_age_range_task
    then_i_see_the(:teacher_age_range_page)

    when_i_fill_in_the_age_range
    then_i_see_the(:teacher_application_page)
    and_i_see_the_completed_age_range_task
  end

  it "records subjects" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_subjects_task

    when_i_click_the_subjects_task
    then_i_see_the(:teacher_subjects_page)

    when_i_fill_in_the_subjects
    then_i_see_the(:teacher_application_page)
    and_i_see_the_completed_subjects_task
  end

  private

  def given_an_application_form_exists
    application_form
  end

  def and_i_see_the_age_range_task
    expect(teacher_application_page.age_range_task_item).to_not be_nil
  end

  def when_i_click_the_age_range_task
    teacher_application_page.age_range_task_item.click
  end

  def and_i_see_the_subjects_task
    expect(teacher_application_page.subjects_task_item).to_not be_nil
  end

  def when_i_click_the_subjects_task
    teacher_application_page.subjects_task_item.click
  end

  def when_i_fill_in_the_age_range
    teacher_age_range_page.form.minimum_field.fill_in with: "9"
    teacher_age_range_page.form.maximum_field.fill_in with: "11"
    teacher_age_range_page.form.continue_button.click
  end

  def when_i_fill_in_the_subjects
    teacher_subjects_page.form.subject_1_field.fill_in with: "French"
    teacher_subjects_page.form.continue_button.click
  end

  def and_i_see_the_completed_age_range_task
    expect(teacher_application_page.age_range_task_item.status_tag.text).to eq(
      "Completed",
    )
  end

  def and_i_see_the_completed_subjects_task
    expect(teacher_application_page.subjects_task_item.status_tag.text).to eq(
      "Completed",
    )
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def application_form
    @application_form ||= create(:application_form, teacher:)
  end
end
