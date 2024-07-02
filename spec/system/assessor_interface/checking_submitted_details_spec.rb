# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor check submitted details", type: :system do
  before do
    given_there_is_an_application_form
    given_i_am_authorized_as_an_assessor_user
  end

  it "allows passing the personal information" do
    when_i_visit_the(
      :assessor_check_personal_information_page,
      reference:,
      assessment_id:,
      section_id: section_id("personal_information"),
    )
    then_i_see_the_personal_information

    when_i_choose_check_personal_information_yes
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_check_personal_information_completed
  end

  it "allows failing the personal information" do
    when_i_visit_the(
      :assessor_check_personal_information_page,
      reference:,
      assessment_id:,
      section_id: section_id("personal_information"),
    )
    then_i_see_the_personal_information

    when_i_choose_check_personal_information_no
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_check_personal_information_completed
  end

  it "allows viewing personal information once submitted" do
    given_there_are_selected_failure_reasons("personal_information")
    when_i_visit_the(
      :assessor_check_personal_information_page,
      reference:,
      assessment_id:,
      section_id: section_id("personal_information"),
    )
    then_i_see_the_personal_information
  end

  it "allows passing the qualifications" do
    when_i_visit_the(
      :assessor_check_qualifications_page,
      reference:,
      assessment_id:,
      section_id: section_id("qualifications"),
    )
    then_i_see_the_qualifications

    when_i_choose_check_qualifications_yes
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_check_qualifications_completed
  end

  it "allows failing the qualifications" do
    when_i_visit_the(
      :assessor_check_qualifications_page,
      reference:,
      assessment_id:,
      section_id: section_id("qualifications"),
    )
    then_i_see_the_qualifications

    when_i_choose_check_qualifications_no
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_check_qualifications_completed
  end

  it "allows viewing qualifications once submitted" do
    given_there_are_selected_failure_reasons("qualifications")
    when_i_visit_the(
      :assessor_check_qualifications_page,
      reference:,
      assessment_id:,
      section_id: section_id("qualifications"),
    )
    then_i_see_the_qualifications
  end

  it "allows passing the age range and subjects" do
    when_i_visit_the(
      :assessor_verify_age_range_subjects_page,
      reference:,
      assessment_id:,
      section_id: section_id("age_range_subjects"),
    )
    then_i_see_the_age_range_and_subjects

    when_i_fill_in_age_range
    and_i_fill_in_subjects
    and_i_choose_verify_age_range_subjects_yes
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_verify_age_range_subjects_completed
  end

  it "allows failing the age range and subjects" do
    when_i_visit_the(
      :assessor_verify_age_range_subjects_page,
      reference:,
      assessment_id:,
      section_id: section_id("age_range_subjects"),
    )
    then_i_see_the_age_range_and_subjects

    when_i_fill_in_age_range
    and_i_fill_in_subjects
    and_i_choose_verify_age_range_subjects_no
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_verify_age_range_subjects_completed
  end

  it "allows viewing age_range_and_subjects once submitted" do
    given_there_are_selected_failure_reasons("age_range_subjects")
    when_i_visit_the(
      :assessor_verify_age_range_subjects_page,
      reference:,
      assessment_id:,
      section_id: section_id("age_range_subjects"),
    )
    then_i_see_the_age_range_and_subjects
  end

  it "allows passing the work history" do
    when_i_visit_the(
      :assessor_check_work_history_page,
      reference:,
      assessment_id:,
      section_id: section_id("work_history"),
    )
    then_i_see_the_work_history

    when_i_choose_check_work_history_yes
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_check_work_history_completed
  end

  it "allows failing the work history" do
    when_i_visit_the(
      :assessor_check_work_history_page,
      reference:,
      assessment_id:,
      section_id: section_id("work_history"),
    )
    then_i_see_the_work_history

    when_i_choose_check_work_history_no
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_check_work_history_completed
  end

  it "allows viewing work history once submitted" do
    given_there_are_selected_failure_reasons("work_history")
    when_i_visit_the(
      :assessor_check_work_history_page,
      reference:,
      assessment_id:,
      section_id: section_id("work_history"),
    )
    then_i_see_the_work_history
  end

  it "allows passing the professional standing" do
    when_i_visit_the(
      :assessor_check_professional_standing_page,
      reference:,
      assessment_id:,
      section_id: section_id("professional_standing"),
    )
    then_i_see_the_professional_standing

    when_i_choose_check_professional_standing_yes
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_check_professional_standing_completed
  end

  it "allows failing the professional standing" do
    when_i_visit_the(
      :assessor_check_professional_standing_page,
      reference:,
      assessment_id:,
      section_id: section_id("professional_standing"),
    )
    then_i_see_the_professional_standing

    when_i_choose_check_professional_standing_no
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_check_professional_standing_completed
  end

  it "allows passing the professional standing without work history" do
    given_application_form_doesnt_need_work_history

    when_i_visit_the(
      :assessor_check_professional_standing_page,
      reference:,
      assessment_id:,
      section_id: section_id("professional_standing"),
    )
    then_i_see_the_professional_standing

    when_i_choose_full_registration
    and_i_choose_induction_not_required
    and_i_choose_check_professional_standing_yes
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_check_professional_standing_completed
  end

  it "allows viewing professional standing once submitted" do
    given_there_are_selected_failure_reasons("professional_standing")
    when_i_visit_the(
      :assessor_check_professional_standing_page,
      reference:,
      assessment_id:,
      section_id: section_id("professional_standing"),
    )
    then_i_see_the_professional_standing
  end

  private

  def given_there_is_an_application_form
    application_form
  end

  def given_application_form_doesnt_need_work_history
    application_form.update!(
      needs_work_history: false,
      created_at: Date.new(2023, 2, 1),
    )
  end

  def then_i_see_the_personal_information
    expect(
      assessor_check_personal_information_page
        .personal_information
        .given_names
        .text,
    ).to eq(application_form.given_names)
    expect(
      assessor_check_personal_information_page
        .personal_information
        .family_name
        .text,
    ).to eq(application_form.family_name)
  end

  def when_i_choose_check_personal_information_yes
    assessor_check_personal_information_page.form.true_radio_item.choose
    assessor_check_personal_information_page.form.continue_button.click
  end

  def and_i_see_check_personal_information_completed
    expect(
      assessor_application_page.personal_information_task.status_tag.text,
    ).to eq("Completed")
  end

  def when_i_choose_check_personal_information_no
    assessor_check_personal_information_page.form.false_radio_item.choose
    assessor_check_personal_information_page
      .form
      .failure_reason_checkbox_items
      .first
      .checkbox
      .click
    assessor_check_personal_information_page
      .form
      .failure_reason_note_textareas
      .first.fill_in with: "Note."
    assessor_check_personal_information_page.form.continue_button.click
  end

  def then_i_see_the_qualifications
    teaching_qualification =
      application_form.qualifications.find(&:is_teaching?)
    expect(
      assessor_check_qualifications_page
        .teaching_qualification
        .title_value
        .text,
    ).to eq(teaching_qualification.title)
  end

  def when_i_choose_check_qualifications_yes
    assessor_check_qualifications_page.form.true_radio_item.choose
    assessor_check_qualifications_page.form.continue_button.click
  end

  def when_i_choose_check_qualifications_no
    assessor_check_qualifications_page.form.false_radio_item.choose
    assessor_check_qualifications_page
      .form
      .failure_reason_checkbox_items
      .first
      .checkbox
      .click
    assessor_check_qualifications_page
      .form
      .failure_reason_note_textareas
      .first.fill_in with: "Note."
    assessor_check_qualifications_page.form.continue_button.click
  end

  def and_i_see_check_qualifications_completed
    expect(assessor_application_page.qualifications_task.status_tag.text).to eq(
      "Completed",
    )
  end

  def then_i_see_the_age_range_and_subjects
    expect(
      assessor_verify_age_range_subjects_page.age_range.heading.text,
    ).to eq("Enter the age range you can teach")
    expect(assessor_verify_age_range_subjects_page.subjects.heading.text).to eq(
      "Enter the subjects you can teach",
    )
  end

  def when_i_fill_in_age_range
    assessor_verify_age_range_subjects_page.age_range_form.minimum.fill_in with:
      "7"
    assessor_verify_age_range_subjects_page.age_range_form.maximum.fill_in with:
      "11"
    assessor_verify_age_range_subjects_page.age_range_form.note.fill_in with:
      "A note."
  end

  def and_i_fill_in_subjects
    assessor_verify_age_range_subjects_page.subjects_form.first_field.fill_in with:
      "Physics"
    assessor_verify_age_range_subjects_page.subjects_form.note_textarea.fill_in with:
      "Another note."
  end

  def and_i_choose_verify_age_range_subjects_yes
    assessor_verify_age_range_subjects_page.form.true_radio_item.choose
    assessor_verify_age_range_subjects_page.form.continue_button.click
  end

  def and_i_choose_verify_age_range_subjects_no
    assessor_verify_age_range_subjects_page.form.false_radio_item.choose
    assessor_verify_age_range_subjects_page
      .form
      .failure_reason_checkbox_items
      .first
      .checkbox
      .click
    assessor_verify_age_range_subjects_page
      .form
      .failure_reason_note_textareas
      .first.fill_in with: "Note."
    assessor_verify_age_range_subjects_page.form.continue_button.click
  end

  def and_i_see_verify_age_range_subjects_completed
    expect(
      assessor_application_page.age_range_subjects_task.status_tag.text,
    ).to eq("Completed")
  end

  def then_i_see_the_work_history
    most_recent_role = application_form.work_histories.first
    expect(
      assessor_check_work_history_page.most_recent_role.school_name.text,
    ).to eq(most_recent_role.school_name)
  end

  def when_i_choose_check_work_history_yes
    assessor_check_work_history_page.form.true_radio_item.choose
    assessor_check_work_history_page.form.continue_button.click
  end

  def and_i_see_check_work_history_completed
    expect(assessor_application_page.work_history_task.status_tag.text).to eq(
      "Completed",
    )
  end

  def when_i_choose_check_work_history_no
    assessor_check_work_history_page.form.false_radio_item.choose
    assessor_check_work_history_page
      .form
      .failure_reason_checkbox_items
      .first
      .checkbox
      .click
    assessor_check_work_history_page.school_checkbox_items.first.click
    assessor_check_work_history_page
      .form
      .failure_reason_note_textareas
      .first.fill_in with: "Note."
    assessor_check_work_history_page.form.continue_button.click
  end

  def then_i_see_the_professional_standing
    expect(
      assessor_check_professional_standing_page
        .proof_of_recognition
        .registration_number
        .text,
    ).to eq(application_form.registration_number)
  end

  def when_i_choose_check_professional_standing_yes
    assessor_check_professional_standing_page.form.true_radio_item.choose
    assessor_check_professional_standing_page.form.continue_button.click
  end

  alias_method :and_i_choose_check_professional_standing_yes,
               :when_i_choose_check_professional_standing_yes

  def when_i_choose_full_registration
    assessor_check_professional_standing_page
      .scotland_full_registration_form
      .true_radio_item
      .choose
  end

  def and_i_choose_induction_not_required
    assessor_check_professional_standing_page
      .induction_required_form
      .false_radio_item
      .choose
  end

  def and_i_see_check_professional_standing_completed
    expect(
      assessor_application_page.professional_standing_task.status_tag.text,
    ).to eq("Completed")
  end

  def when_i_choose_check_professional_standing_no
    assessor_check_professional_standing_page.form.false_radio_item.choose
    assessor_check_professional_standing_page
      .form
      .failure_reason_checkbox_items
      .first
      .checkbox
      .click
    assessor_check_professional_standing_page
      .form
      .failure_reason_note_textareas
      .first.fill_in with: "Note."
    assessor_check_professional_standing_page.form.continue_button.click
  end

  def application_form
    @application_form ||=
      begin
        application_form =
          create(
            :application_form,
            :with_teaching_qualification,
            :with_work_history,
            :with_registration_number,
            :with_personal_information,
            :submitted,
            :with_assessment,
            region: create(:region, :in_country, country_code: "GB-SCT"),
          )

        create(
          :assessment_section,
          :personal_information,
          failure_reasons: %w[identification_document_expired],
          assessment: application_form.assessment,
        )
        create(
          :assessment_section,
          :qualifications,
          failure_reasons: %w[identification_document_expired],
          assessment: application_form.assessment,
        )
        create(
          :assessment_section,
          :age_range_subjects,
          failure_reasons: %w[identification_document_expired],
          assessment: application_form.assessment,
        )
        create(
          :assessment_section,
          :work_history,
          assessment: application_form.assessment,
          failure_reasons: %w[
            school_details_cannot_be_verified
            identification_document_expired
          ],
        )
        create(
          :assessment_section,
          :professional_standing,
          failure_reasons: %w[identification_document_expired],
          assessment: application_form.assessment,
        )

        application_form
      end
  end

  delegate :reference, to: :application_form

  def assessment_id
    application_form.assessment.id
  end

  def section_id(key)
    application_form.assessment.sections.find_by(key:).id
  end

  def given_there_are_selected_failure_reasons(key)
    create(
      :selected_failure_reason,
      assessment_section_id: section_id(key),
      key: "identification_document_expired",
    )
  end
end
