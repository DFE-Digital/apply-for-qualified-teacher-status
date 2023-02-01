require "rails_helper"

RSpec.describe "Assessor check submitted details", type: :system do
  before do
    given_the_service_is_open
    given_there_is_an_application_form
    given_i_am_authorized_as_an_assessor_user
  end

  it "allows passing the personal information" do
    when_i_visit_the(
      :check_personal_information_page,
      application_id:,
      assessment_id:,
    )
    then_i_see_the_personal_information

    when_i_choose_check_personal_information_yes
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_check_personal_information_completed
  end

  it "allows failing the personal information" do
    when_i_visit_the(
      :check_personal_information_page,
      application_id:,
      assessment_id:,
    )
    then_i_see_the_personal_information

    when_i_choose_check_personal_information_no
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_check_personal_information_completed
  end

  it "allows passing the qualifications" do
    when_i_visit_the(
      :check_qualifications_page,
      application_id:,
      assessment_id:,
    )
    then_i_see_the_qualifications

    when_i_choose_check_qualifications_yes
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_check_qualifications_completed
  end

  it "allows failing the qualifications" do
    when_i_visit_the(
      :check_qualifications_page,
      application_id:,
      assessment_id:,
    )
    then_i_see_the_qualifications

    when_i_choose_check_qualifications_no
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_check_qualifications_completed
  end

  it "allows passing the age range and subjects" do
    when_i_visit_the(
      :verify_age_range_subjects_page,
      application_id:,
      assessment_id:,
    )
    then_i_see_the_age_range_and_subjects

    when_i_fill_in_age_range
    and_i_fill_in_subjects
    and_i_choose_verify_age_range_subjects_yes
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_verify_age_range_subjects_completed
  end

  it "allows failing the age range and subjects" do
    when_i_visit_the(
      :verify_age_range_subjects_page,
      application_id:,
      assessment_id:,
    )
    then_i_see_the_age_range_and_subjects

    when_i_fill_in_age_range
    and_i_fill_in_subjects
    and_i_choose_verify_age_range_subjects_no
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_verify_age_range_subjects_completed
  end

  it "allows passing the work history" do
    when_i_visit_the(:check_work_history_page, application_id:, assessment_id:)
    then_i_see_the_work_history

    when_i_choose_check_work_history_yes
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_check_work_history_completed
  end

  it "allows failing the work history" do
    when_i_visit_the(:check_work_history_page, application_id:, assessment_id:)
    then_i_see_the_work_history

    when_i_choose_check_work_history_no
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_check_work_history_completed
  end

  it "allows passing the professional standing" do
    when_i_visit_the(
      :check_professional_standing_page,
      application_id:,
      assessment_id:,
    )
    then_i_see_the_professional_standing

    when_i_choose_check_professional_standing_yes
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_check_professional_standing_completed
  end

  it "allows failing the professional standing" do
    when_i_visit_the(
      :check_professional_standing_page,
      application_id:,
      assessment_id:,
    )
    then_i_see_the_professional_standing

    when_i_choose_check_professional_standing_no
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_check_professional_standing_completed
  end

  it "allows passing the professional standing without work history" do
    given_application_form_doesnt_need_work_history

    when_i_visit_the(
      :check_professional_standing_page,
      application_id:,
      assessment_id:,
    )
    then_i_see_the_professional_standing

    when_i_choose_full_registration
    and_i_choose_check_professional_standing_yes
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_check_professional_standing_completed
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
      check_personal_information_page.personal_information.given_names.text,
    ).to eq(application_form.given_names)
    expect(
      check_personal_information_page.personal_information.family_name.text,
    ).to eq(application_form.family_name)
  end

  def when_i_choose_check_personal_information_yes
    check_personal_information_page.form.yes_radio_item.choose
    check_personal_information_page.form.continue_button.click
  end

  def personal_information_task_item
    assessor_application_page.task_list.tasks.first.items.find do |item|
      item.link.text == "Check personal information"
    end
  end

  def and_i_see_check_personal_information_completed
    expect(
      assessor_application_page.personal_information_task.status_tag.text,
    ).to eq("COMPLETED")
  end

  def when_i_choose_check_personal_information_no
    check_personal_information_page.form.no_radio_item.choose
    check_personal_information_page
      .form
      .failure_reason_checkbox_items
      .first
      .checkbox
      .click
    check_personal_information_page
      .form
      .failure_reason_note_textareas
      .first.fill_in with: "Note."
    check_personal_information_page.form.continue_button.click
  end

  def then_i_see_the_qualifications
    teaching_qualification =
      application_form.qualifications.find(&:is_teaching_qualification?)
    expect(check_qualifications_page.teaching_qualification.title.text).to eq(
      teaching_qualification.title,
    )
  end

  def when_i_choose_check_qualifications_yes
    check_qualifications_page.form.yes_radio_item.choose
    check_qualifications_page.form.continue_button.click
  end

  def when_i_choose_check_qualifications_no
    check_qualifications_page.form.no_radio_item.choose
    check_qualifications_page
      .form
      .failure_reason_checkbox_items
      .first
      .checkbox
      .click
    check_qualifications_page
      .form
      .failure_reason_note_textareas
      .first.fill_in with: "Note."
    check_qualifications_page.form.continue_button.click
  end

  def and_i_see_check_qualifications_completed
    expect(assessor_application_page.qualifications_task.status_tag.text).to eq(
      "COMPLETED",
    )
  end

  def then_i_see_the_age_range_and_subjects
    expect(verify_age_range_subjects_page.age_range.heading.text).to eq(
      "Enter the age range you can teach",
    )
    expect(verify_age_range_subjects_page.subjects.heading.text).to eq(
      "Enter the subjects you can teach",
    )
  end

  def when_i_fill_in_age_range
    verify_age_range_subjects_page.age_range_form.minimum.fill_in with: "7"
    verify_age_range_subjects_page.age_range_form.maximum.fill_in with: "11"
    verify_age_range_subjects_page.age_range_form.note.fill_in with: "A note."
  end

  def and_i_fill_in_subjects
    verify_age_range_subjects_page.subjects_form.first_field.fill_in with:
      "Physics"
    verify_age_range_subjects_page.subjects_form.note_textarea.fill_in with:
      "Another note."
  end

  def and_i_choose_verify_age_range_subjects_yes
    verify_age_range_subjects_page.form.yes_radio_item.choose
    verify_age_range_subjects_page.form.continue_button.click
  end

  def and_i_choose_verify_age_range_subjects_no
    verify_age_range_subjects_page.form.no_radio_item.choose
    verify_age_range_subjects_page
      .form
      .failure_reason_checkbox_items
      .first
      .checkbox
      .click
    verify_age_range_subjects_page
      .form
      .failure_reason_note_textareas
      .first.fill_in with: "Note."
    verify_age_range_subjects_page.form.continue_button.click
  end

  def and_i_see_verify_age_range_subjects_completed
    expect(
      assessor_application_page.age_range_subjects_task.status_tag.text,
    ).to eq("COMPLETED")
  end

  def then_i_see_the_work_history
    most_recent_role = application_form.work_histories.first
    expect(check_work_history_page.most_recent_role.school_name.text).to eq(
      most_recent_role.school_name,
    )
  end

  def when_i_choose_check_work_history_yes
    check_work_history_page.form.yes_radio_item.choose
    check_work_history_page.form.continue_button.click
  end

  def and_i_see_check_work_history_completed
    expect(assessor_application_page.work_history_task.status_tag.text).to eq(
      "COMPLETED",
    )
  end

  def when_i_choose_check_work_history_no
    check_work_history_page.form.no_radio_item.choose
    check_work_history_page
      .form
      .failure_reason_checkbox_items
      .first
      .checkbox
      .click
    check_work_history_page
      .form
      .failure_reason_note_textareas
      .first.fill_in with: "Note."
    check_work_history_page.form.continue_button.click
  end

  def then_i_see_the_professional_standing
    expect(
      check_professional_standing_page
        .proof_of_recognition
        .registration_number
        .text,
    ).to eq(application_form.registration_number)
  end

  def when_i_choose_check_professional_standing_yes
    check_professional_standing_page.form.yes_radio_item.choose
    check_professional_standing_page.form.continue_button.click
  end

  alias_method :and_i_choose_check_professional_standing_yes,
               :when_i_choose_check_professional_standing_yes

  def when_i_choose_full_registration
    check_professional_standing_page
      .induction_required_form
      .no_radio_item
      .choose
  end

  def and_i_see_check_professional_standing_completed
    expect(
      assessor_application_page.professional_standing_task.status_tag.text,
    ).to eq("COMPLETED")
  end

  def when_i_choose_check_professional_standing_no
    check_professional_standing_page.form.no_radio_item.choose
    check_professional_standing_page
      .form
      .failure_reason_checkbox_items
      .first
      .checkbox
      .click
    check_professional_standing_page
      .form
      .failure_reason_note_textareas
      .first.fill_in with: "Note."
    check_professional_standing_page.form.continue_button.click
  end

  def application_form
    @application_form ||=
      begin
        application_form =
          create(
            :application_form,
            :old_regs,
            :with_completed_qualification,
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
          assessment: application_form.assessment,
        )
        create(
          :assessment_section,
          :qualifications,
          assessment: application_form.assessment,
        )
        create(
          :assessment_section,
          :age_range_subjects,
          assessment: application_form.assessment,
        )
        create(
          :assessment_section,
          :work_history,
          assessment: application_form.assessment,
        )
        create(
          :assessment_section,
          :professional_standing,
          assessment: application_form.assessment,
        )

        application_form
      end
  end

  def application_id
    application_form.id
  end

  def assessment_id
    application_form.assessment.id
  end
end
