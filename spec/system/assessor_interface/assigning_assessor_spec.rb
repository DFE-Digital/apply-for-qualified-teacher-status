# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assigning an assessor", type: :system do
  it "assigns an assessor" do
    given_the_service_is_open
    given_i_am_authorized_as_a_user(assessor)
    given_there_is_an_application_form
    given_an_assessor_exists

    when_i_visit_the(:assign_assessor_page, application_id: application_form.id)
    and_i_select_an_assessor
    then_i_see_the(
      :assessor_application_page,
      application_id: application_form.id,
    )
    and_the_assessor_is_assigned_to_the_application_form
  end

  it "assigns a reviewer" do
    given_the_service_is_open
    given_i_am_authorized_as_a_user(assessor)
    given_there_is_an_application_form
    given_an_assessor_exists

    when_i_visit_the(:assign_reviewer_page, application_id: application_form.id)
    and_i_select_a_reviewer
    then_i_see_the(
      :assessor_application_page,
      application_id: application_form.id,
    )
    and_the_assessor_is_assigned_as_reviewer_to_the_application_form
  end

  private

  def given_there_is_an_application_form
    application_form
  end

  def given_an_assessor_exists
    assessor
  end

  def and_i_select_an_assessor
    assign_assessor_page.assessors.second.input.click
    assign_assessor_page.continue_button.click
  end

  def and_the_assessor_is_assigned_to_the_application_form
    expect(assessor_application_page.overview.assessor_name.text).to eq(
      assessor.name,
    )
  end

  def when_i_visit_the_assign_reviewer_page
    assign_reviewer_page.load(application_id: application_form.id)
  end

  def and_i_select_a_reviewer
    assign_reviewer_page.reviewers.second.input.click
    assign_reviewer_page.continue_button.click
  end

  def and_the_assessor_is_assigned_as_reviewer_to_the_application_form
    expect(assessor_application_page.overview.reviewer_name.text).to eq(
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
    @assessor ||= create(:staff, :with_award_decline_permission, :confirmed)
  end
end
