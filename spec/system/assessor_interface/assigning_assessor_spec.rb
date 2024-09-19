# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assigning an assessor", type: :system do
  before { given_there_is_an_application_form }

  it "does not allow any access if user is archived" do
    given_i_am_authorized_as_an_archived_assessor_user

    when_i_visit_the(:assessor_assign_assessor_page, reference:)
    then_i_see_the_forbidden_page
  end

  it "assigns an assessor" do
    given_i_am_authorized_as_an_assessor_user

    when_i_visit_the(:assessor_assign_assessor_page, reference:)
    and_i_select_an_assessor
    then_i_see_the(:assessor_application_page, reference:)
    and_the_assessor_is_assigned_to_the_application_form
  end

  it "assigns a reviewer" do
    given_i_am_authorized_as_an_assessor_user

    when_i_visit_the(:assessor_assign_reviewer_page, reference:)
    and_i_select_a_reviewer
    then_i_see_the(:assessor_application_page, reference:)
    and_the_assessor_is_assigned_as_reviewer_to_the_application_form
  end

  it "requires permission" do
    given_i_am_authorized_as_a_support_user

    when_i_visit_the(:assessor_assign_assessor_page, reference:)
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

  delegate :reference, to: :application_form

  def assessor
    @user
  end
end
