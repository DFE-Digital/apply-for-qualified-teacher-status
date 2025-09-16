# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor change teaching qualification", type: :system do
  let(:application_form) do
    create :application_form,
           :submitted,
           :with_personal_information,
           teaching_qualification_part_of_degree: false
  end

  let(:reference) { application_form.reference }

  let(:assessment) { create(:assessment, application_form:) }

  let!(:initial_teaching_qualification) do
    create :qualification,
           :completed,
           application_form:,
           institution_country_code: application_form.country.code,
           created_at: 2.hours.ago
  end

  let!(:initial_bachelor_qualification) do
    create :qualification,
           :completed,
           application_form:,
           institution_country_code: application_form.country.code,
           created_at: 1.hour.ago
  end

  let!(:qualifications_assessment_section) do
    create(:assessment_section, :qualifications, assessment:)
  end

  before { create(:work_history, :completed, application_form:) }

  it "checks permissions for editing teaching qualification" do
    given_i_am_authorized_as_a_user(assessor)

    when_i_visit_the(
      :assessor_edit_teaching_qualification_page,
      reference:,
      qualification_id: initial_teaching_qualification.id,
    )
    then_i_see_the_forbidden_page
  end

  it "does not allow access to edit teaching qualification if user is archived" do
    given_i_am_authorized_as_an_archived_user(manager)

    when_i_visit_the(
      :assessor_edit_teaching_qualification_page,
      reference:,
      qualification_id: initial_teaching_qualification.id,
    )
    then_i_see_the_forbidden_page
  end

  it "does not allow access to edit teaching qualification if not a teaching qualification" do
    given_i_am_authorized_as_a_user(manager)

    when_i_visit_the(
      :assessor_edit_teaching_qualification_page,
      reference:,
      assessment_id: assessment.id,
      qualification_id: initial_bachelor_qualification.id,
    )

    then_i_see_the(
      :assessor_assessment_section_page,
      reference:,
      assessment_id: assessment.id,
      section_id: qualifications_assessment_section.id,
    )
    and_i_see_an_flash_message_that_i_cannot_update_qualification
  end

  it "updates the new teaching qualification" do
    given_i_am_authorized_as_a_user(manager)

    when_i_visit_the(
      :assessor_assessment_section_page,
      reference:,
      assessment_id: assessment.id,
      section_id: qualifications_assessment_section.id,
    )
    then_i_can_see_an_option_to_edit_teaching_qualification

    when_i_click_on_assign_as_teaching_qualification
    then_i_see_the(
      :assessor_edit_teaching_qualification_page,
      reference:,
      qualification_id: initial_teaching_qualification.id,
    )
    then_i_see_the_content_for_changing_applicant_teaching_qualification

    when_i_update_the_qualification_details
    then_i_see_the(
      :assessor_assessment_section_page,
      reference:,
      assessment_id: assessment.id,
      section_id: qualifications_assessment_section.id,
    )
    and_i_see_an_success_message_that_the_teaching_qualification_has_been_updated
  end

  it "display validation errors dates are a mismatch" do
    given_i_am_authorized_as_a_user(manager)

    when_i_visit_the(
      :assessor_assessment_section_page,
      reference:,
      assessment_id: assessment.id,
      section_id: qualifications_assessment_section.id,
    )
    then_i_can_see_an_option_to_edit_teaching_qualification

    when_i_click_on_assign_as_teaching_qualification
    then_i_see_the(
      :assessor_edit_teaching_qualification_page,
      reference:,
      qualification_id: initial_teaching_qualification.id,
    )
    then_i_see_the_content_for_changing_applicant_teaching_qualification

    when_i_update_the_qualification_details_with_mismatch_dates
    then_i_see_the_validation_errors_for_mismatch_of_dates
  end

  it "display validation error when certificate date causes work history to go below 9 months" do
    given_i_am_authorized_as_a_user(manager)

    when_i_visit_the(
      :assessor_assessment_section_page,
      reference:,
      assessment_id: assessment.id,
      section_id: qualifications_assessment_section.id,
    )
    then_i_can_see_an_option_to_edit_teaching_qualification

    when_i_click_on_assign_as_teaching_qualification
    then_i_see_the(
      :assessor_edit_teaching_qualification_page,
      reference:,
      qualification_id: initial_teaching_qualification.id,
    )
    then_i_see_the_content_for_changing_applicant_teaching_qualification

    when_i_update_the_qualification_details_with_certificate_date_resulting_work_history_error
    then_i_see_the_validation_errors_for_work_history_less_than_9_months
  end

  context "when application is in verification" do
    before { application_form.update!(stage: "verification") }

    it "does not allow access to assign teaching qualification" do
      given_i_am_authorized_as_a_user(manager)

      when_i_visit_the(
        :assessor_assessment_section_page,
        reference:,
        assessment_id: assessment.id,
        section_id: qualifications_assessment_section.id,
      )
      then_i_see_cannot_see_option_to_edit_the_qualification
    end
  end

  def and_i_see_an_flash_message_that_i_cannot_update_qualification
    expect(assessor_assessment_section_page).to have_content(
      "Other qualifications cannot be updated",
    )
  end

  def and_i_see_an_flash_message_that_the_application_is_in_incorrect_stage
    expect(assessor_assessment_section_page).to have_content(
      "Teaching qualification can only be update while the application is in assessment or review stage",
    )
  end

  def then_i_can_see_an_option_to_edit_teaching_qualification
    qualification_summary =
      assessor_assessment_section_page.find("#teaching-qualification-section")

    expect(qualification_summary).to have_content("Edit")
  end

  def then_i_see_cannot_see_option_to_edit_the_qualification
    qualification_summary =
      assessor_assessment_section_page.find("#teaching-qualification-section")

    expect(qualification_summary).not_to have_content("Edit")
  end

  def when_i_click_on_assign_as_teaching_qualification
    click_on "Edit"
  end

  def then_i_see_the_content_for_changing_applicant_teaching_qualification
    expect(assessor_assign_teaching_qualification_page.heading).to have_content(
      "Change details for ‘#{initial_teaching_qualification.title}’ teaching qualification",
    )
  end

  def and_i_see_an_success_message_that_the_teaching_qualification_has_been_updated
    expect(assessor_assessment_section_page).to have_content(
      "New qualification title teaching qualification has been updated",
    )

    teaching_qualification_section =
      assessor_assessment_section_page.find("#teaching-qualification-section")

    expect(teaching_qualification_section).to have_content(
      "New qualification title",
    )
    expect(teaching_qualification_section).to have_content(
      "New qualification institution name",
    )

    expect(teaching_qualification_section).to have_content("January 2001")

    expect(teaching_qualification_section).to have_content("January 2005")

    expect(teaching_qualification_section).to have_content("July 2005")
  end

  def when_i_update_the_qualification_details
    assessor_edit_teaching_qualification_page.form.title_field.fill_in with:
      "New qualification title"
    assessor_edit_teaching_qualification_page.form.institution_name_field.fill_in with:
      "New qualification institution name"

    assessor_edit_teaching_qualification_page.form.start_date_month_field.fill_in with:
      "1"
    assessor_edit_teaching_qualification_page.form.start_date_year_field.fill_in with:
      "2001"

    assessor_edit_teaching_qualification_page.form.complete_date_month_field.fill_in with:
      "1"
    assessor_edit_teaching_qualification_page.form.complete_date_year_field.fill_in with:
      "2005"

    assessor_edit_teaching_qualification_page.form.certificate_date_month_field.fill_in with:
      "7"
    assessor_edit_teaching_qualification_page.form.certificate_date_year_field.fill_in with:
      "2005"

    assessor_edit_teaching_qualification_page
      .form
      .true_part_of_degree_radio_item
      .click

    assessor_edit_teaching_qualification_page.form.submit_button.click
  end

  def when_i_update_the_qualification_details_with_mismatch_dates
    assessor_edit_teaching_qualification_page.form.start_date_month_field.fill_in with:
      "1"
    assessor_edit_teaching_qualification_page.form.start_date_year_field.fill_in with:
      "2005"

    assessor_edit_teaching_qualification_page.form.complete_date_month_field.fill_in with:
      "1"
    assessor_edit_teaching_qualification_page.form.complete_date_year_field.fill_in with:
      "2004"

    assessor_edit_teaching_qualification_page.form.certificate_date_month_field.fill_in with:
      "7"
    assessor_edit_teaching_qualification_page.form.certificate_date_year_field.fill_in with:
      "2003"

    assessor_edit_teaching_qualification_page.form.submit_button.click
  end

  def when_i_update_the_qualification_details_with_certificate_date_resulting_work_history_error
    assessor_edit_teaching_qualification_page.form.certificate_date_month_field.fill_in with:
      Date.current.month
    assessor_edit_teaching_qualification_page.form.certificate_date_year_field.fill_in with:
      Date.current.year

    assessor_edit_teaching_qualification_page.form.submit_button.click
  end

  def when_i_click_to_go_back
    click_on "Go back"
  end

  def and_i_see_that_the_teaching_qualification_has_not_changed
    teaching_qualification_section =
      assessor_assessment_section_page.find("#teaching-qualification-section")
    other_qualifications_section =
      assessor_assessment_section_page.find("#other-qualifications-section")

    expect(teaching_qualification_section).to have_content(
      initial_teaching_qualification.title,
    )

    expect(other_qualifications_section).to have_content(
      initial_bachelor_qualification.title,
    )
  end

  def then_i_see_the_validation_errors_for_mismatch_of_dates
    expect(assessor_edit_teaching_qualification_page).to have_content(
      "The qualification completed date must be after the qualification" \
        " start date and on or before the qualification awarded date",
    )
    expect(assessor_edit_teaching_qualification_page).to have_content(
      "The qualification awarded date must be on or after the qualification completed date",
    )
  end

  def then_i_see_the_validation_errors_for_work_history_less_than_9_months
    expect(assessor_edit_teaching_qualification_page).to have_content(
      "The qualification awarded date cannot be changed because the applicant will" \
        " have less than 9 months of work experience",
    )
  end

  def assessor
    create(:staff, :with_assess_permission)
  end

  def manager
    create(:staff, :with_change_work_history_and_qualification_permission)
  end
end
