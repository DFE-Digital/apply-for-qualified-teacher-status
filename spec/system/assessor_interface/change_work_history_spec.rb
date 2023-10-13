# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor change work history", type: :system do
  before do
    given_the_service_is_open
    given_there_is_an_application_form
  end

  it "checks manage applications permission" do
    given_i_am_authorized_as_a_user(assessor)

    when_i_visit_the(
      :assessor_edit_work_history_page,
      application_form_id:,
      work_history_id:,
    )
    then_i_see_the_forbidden_page
  end

  it "allows changing work history from initial assessment" do
    given_i_am_authorized_as_a_user(manager)

    when_i_visit_the(
      :assessor_check_work_history_page,
      application_id:,
      assessment_id:,
      section_id: assessment_section.id,
    )
    then_i_see_the(:assessor_check_work_history_page)

    when_i_click_on_change_from_assessment
    then_i_see_the(
      :assessor_edit_work_history_page,
      application_form_id:,
      work_history_id:,
    )

    when_i_fill_in_the_contact_information
    then_i_see_the(:assessor_application_page, application_id:)
  end

  it "allows changing work history from verification" do
    given_i_am_authorized_as_a_user(manager)

    when_i_visit_the(
      :assessor_edit_reference_request_page,
      application_id:,
      assessment_id:,
      id: reference_request.id,
    )
    then_i_see_the(:assessor_edit_reference_request_page)

    when_i_click_on_change_from_verification
    then_i_see_the(
      :assessor_edit_work_history_page,
      application_form_id:,
      work_history_id:,
    )

    when_i_fill_in_the_contact_information
    then_i_see_the(:assessor_application_page, application_id:)
  end

  def given_there_is_an_application_form
    application_form
  end

  def when_i_click_on_change_from_assessment
    assessor_check_work_history_page
      .cards
      .first
      .find_row(key: "Reference contact’s full name")
      .actions
      .link
      .click
  end

  def when_i_click_on_change_from_verification
    assessor_edit_reference_request_page
      .summary_list
      .find_row(key: "Name of reference")
      .actions
      .link
      .click
  end

  def when_i_fill_in_the_contact_information
    assessor_edit_work_history_page.form.name_field.fill_in with: "New name"
    assessor_edit_work_history_page.form.job_field.fill_in with: "New job"
    assessor_edit_work_history_page.form.email_field.fill_in with:
      "new-email@example.com"
    assessor_edit_work_history_page.form.submit_button.click
  end

  def application_form
    @application_form ||=
      create(:application_form, :submitted, :with_personal_information)
  end

  delegate :id, to: :application_form, prefix: true
  alias_method :application_id, :application_form_id

  def assessment
    @assessment ||= create(:assessment, application_form:)
  end

  delegate :id, to: :assessment, prefix: true

  def work_history
    @work_history ||= create(:work_history, :completed, application_form:)
  end

  delegate :id, to: :work_history, prefix: true

  def assessment_section
    @assessment_section ||=
      begin
        work_history
        create(:assessment_section, :work_history, assessment:)
      end
  end

  def reference_request
    @reference_request ||=
      create(:reference_request, :requested, assessment:, work_history:)
  end

  def assessor
    create(:staff, :confirmed, :with_assess_permission)
  end

  def manager
    create(:staff, :confirmed, :with_change_work_history_permission)
  end
end
