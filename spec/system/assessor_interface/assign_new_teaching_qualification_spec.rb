# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor assign new teaching qualification", type: :system do
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

  let!(:work_history) { create(:work_history, :completed, application_form:) }

  it "checks permissions for assigning new teaching qualification" do
    given_i_am_authorized_as_a_user(assessor)

    when_i_visit_the(
      :assessor_assign_teaching_qualification_page,
      reference:,
      qualification_id: initial_bachelor_qualification.id,
    )
    then_i_see_the_forbidden_page
  end

  it "does not allow access to assign teaching qualification if user is archived" do
    given_i_am_authorized_as_an_archived_user(manager)

    when_i_visit_the(
      :assessor_assign_teaching_qualification_page,
      reference:,
      qualification_id: initial_bachelor_qualification.id,
    )
    then_i_see_the_forbidden_page
  end

  it "does not allow access to assign teaching qualification if qualification is already assigned" do
    given_i_am_authorized_as_a_user(manager)

    when_i_visit_the(
      :assessor_assign_teaching_qualification_page,
      reference:,
      assessment_id: assessment.id,
      qualification_id: initial_teaching_qualification.id,
    )

    then_i_see_the(
      :assessor_assessment_section_page,
      reference:,
      assessment_id: assessment.id,
      section_id: qualifications_assessment_section.id,
    )
    and_i_see_an_flash_message_that_i_cannot_reassign_teaching_qualification
  end

  it "assigns the new teaching qualification" do
    given_i_am_authorized_as_a_user(manager)

    when_i_visit_the(
      :assessor_assessment_section_page,
      reference:,
      assessment_id: assessment.id,
      section_id: qualifications_assessment_section.id,
    )
    then_i_can_see_an_option_to_assign_new_teaching_qualification

    when_i_click_on_assign_as_teaching_qualification
    then_i_see_the(
      :assessor_assign_teaching_qualification_page,
      reference:,
      qualification_id: initial_bachelor_qualification.id,
    )
    then_i_see_the_content_for_changing_applicant_teaching_qualification

    when_i_confirm_that_i_want_to_assign_as_teaching_qualification
    then_i_see_the(
      :assessor_assessment_section_page,
      reference:,
      assessment_id: assessment.id,
      section_id: qualifications_assessment_section.id,
    )
    and_i_see_an_success_message_that_the_teaching_qualification_has_been_reassigned
  end

  context "when other application is from a different country to the one set on application form" do
    before do
      initial_bachelor_qualification.update(institution_country_code: "IR")
    end

    it "does not assign new teaching qualification" do
      given_i_am_authorized_as_a_user(manager)

      when_i_visit_the(
        :assessor_assessment_section_page,
        reference:,
        assessment_id: assessment.id,
        section_id: qualifications_assessment_section.id,
      )
      then_i_can_see_an_option_to_assign_new_teaching_qualification

      when_i_click_on_assign_as_teaching_qualification
      then_i_see_the(
        :assessor_assign_teaching_qualification_page,
        reference:,
        qualification_id: initial_bachelor_qualification.id,
      )
      then_i_see_the_content_for_changing_applicant_teaching_qualification

      when_i_confirm_that_i_want_to_assign_as_teaching_qualification
      then_i_see_the(
        :assessor_assign_teaching_qualification_invalid_country_page,
        reference:,
        qualification_id: initial_bachelor_qualification.id,
      )

      when_i_click_to_go_back
      then_i_see_the(
        :assessor_assessment_section_page,
        reference:,
        assessment_id: assessment.id,
        section_id: qualifications_assessment_section.id,
      )
      and_i_see_that_the_teaching_qualification_has_not_changed
    end
  end

  context "when other application as teaching qualification would result in less than 9 months work history" do
    before do
      work_history.update!(
        start_date: initial_bachelor_qualification.complete_date,
        end_date: initial_bachelor_qualification.complete_date + 6.months,
      )
    end

    it "does not assign new teaching qualification" do
      given_i_am_authorized_as_a_user(manager)

      when_i_visit_the(
        :assessor_assessment_section_page,
        reference:,
        assessment_id: assessment.id,
        section_id: qualifications_assessment_section.id,
      )
      then_i_can_see_an_option_to_assign_new_teaching_qualification

      when_i_click_on_assign_as_teaching_qualification
      then_i_see_the(
        :assessor_assign_teaching_qualification_page,
        reference:,
        qualification_id: initial_bachelor_qualification.id,
      )
      then_i_see_the_content_for_changing_applicant_teaching_qualification

      when_i_confirm_that_i_want_to_assign_as_teaching_qualification
      then_i_see_the(
        :assessor_assign_teaching_qualification_invalid_work_duration_page,
        reference:,
        qualification_id: initial_bachelor_qualification.id,
      )

      when_i_click_to_go_back
      then_i_see_the(
        :assessor_assessment_section_page,
        reference:,
        assessment_id: assessment.id,
        section_id: qualifications_assessment_section.id,
      )
      and_i_see_that_the_teaching_qualification_has_not_changed
    end
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
      then_i_cannot_see_an_option_to_assign_new_teaching_qualification
    end
  end

  def and_i_see_an_flash_message_that_i_cannot_reassign_teaching_qualification
    expect(assessor_assessment_section_page).to have_content(
      "Teaching qualification cannot be assigned as teaching qualification again",
    )
  end

  def and_i_see_an_flash_message_that_the_application_is_in_incorrect_stage
    expect(assessor_assessment_section_page).to have_content(
      "Teaching qualification can only be update while the application is in assessment or review stage",
    )
  end

  def then_i_can_see_an_option_to_assign_new_teaching_qualification
    qualification_summary =
      assessor_assessment_section_page.find("#other-qualifications-section")

    expect(qualification_summary).to have_content(
      "Assign as teaching qualification",
    )
  end

  def then_i_cannot_see_an_option_to_assign_new_teaching_qualification
    qualification_summary =
      assessor_assessment_section_page.find("#other-qualifications-section")

    expect(qualification_summary).not_to have_content(
      "Assign as teaching qualification",
    )
  end

  def when_i_click_on_assign_as_teaching_qualification
    click_on "Assign as teaching qualification"
  end

  def then_i_see_the_content_for_changing_applicant_teaching_qualification
    expect(assessor_assign_teaching_qualification_page.heading).to have_content(
      "Are you sure you want to change the applicant’s teaching qualification?",
    )
    expect(assessor_assign_teaching_qualification_page).to have_content(
      "The applicant’s teaching qualification will be changed to #{initial_bachelor_qualification.title}",
    )
  end

  def and_i_see_an_success_message_that_the_teaching_qualification_has_been_reassigned
    expect(assessor_assessment_section_page).to have_content(
      "#{initial_bachelor_qualification.title} has been assigned as the applicant’s teaching qualification",
    )

    teaching_qualification_section =
      assessor_assessment_section_page.find("#teaching-qualification-section")
    other_qualifications_section =
      assessor_assessment_section_page.find("#other-qualifications-section")

    expect(teaching_qualification_section).to have_content(
      initial_bachelor_qualification.title,
    )

    expect(other_qualifications_section).to have_content(
      initial_teaching_qualification.title,
    )
  end

  def when_i_confirm_that_i_want_to_assign_as_teaching_qualification
    assessor_assign_teaching_qualification_page.confirm_button.click
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

  def assessor
    create(:staff, :with_assess_permission)
  end

  def manager
    create(:staff, :with_change_work_history_and_qualification_permission)
  end
end
