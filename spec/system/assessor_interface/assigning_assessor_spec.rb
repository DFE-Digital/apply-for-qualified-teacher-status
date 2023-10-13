# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assigning an assessor", type: :system do
  before do
    given_the_service_is_open
    given_there_is_an_application_form
  end

  it "assigns an assessor" do
    given_i_am_authorized_as_an_assessor_user

    when_i_visit_the(
      :assessor_assign_assessor_page,
      application_form_id: application_form.id,
    )
    and_i_select_an_assessor
    then_i_see_the(
      :assessor_application_page,
      application_form_id: application_form.id,
    )
    and_the_assessor_is_assigned_to_the_application_form
  end

  it "assigns a reviewer" do
    given_i_am_authorized_as_an_assessor_user

    when_i_visit_the(
      :assessor_assign_reviewer_page,
      application_form_id: application_form.id,
    )
    and_i_select_a_reviewer
    then_i_see_the(
      :assessor_application_page,
      application_form_id: application_form.id,
    )
    and_the_assessor_is_assigned_as_reviewer_to_the_application_form
  end

  it "requires permission" do
    given_i_am_authorized_as_a_support_user

    when_i_visit_the(
      :assessor_assign_assessor_page,
      application_form_id: application_form.id,
    )
    then_i_see_the_forbidden_page
  end

  private

  def given_there_is_an_application_form
    application_form
  end

  def and_i_select_an_assessor
    assessor_assign_assessor_page.assessors.second.input.click
    assessor_assign_assessor_page.continue_button.click
  end

  def and_the_assessor_is_assigned_to_the_application_form
    expect(assessor_application_page.assessor_summary.value).to have_text(
      assessor.name,
    )
  end

  def when_i_visit_the_assign_reviewer_page
    assessor_assign_reviewer_page.load(application_form_id: application_form.id)
  end

  def and_i_select_a_reviewer
    assessor_assign_reviewer_page.reviewers.second.input.click
    assessor_assign_reviewer_page.continue_button.click
  end

  def and_the_assessor_is_assigned_as_reviewer_to_the_application_form
    expect(assessor_application_page.reviewer_summary.value).to have_text(
      assessor.name,
    )
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :with_personal_information,
        :submitted,
        :with_assessment,
      )
  end

  def assessor
    @user
  end
end
