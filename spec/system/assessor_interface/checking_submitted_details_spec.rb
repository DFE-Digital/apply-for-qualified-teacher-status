require "rails_helper"

RSpec.describe "Assessor check submitted details", type: :system do
  before do
    given_the_service_is_open
    given_an_assessor_exists
    given_there_is_an_application_form
    given_i_am_authorized_as_an_assessor_user(assessor)
  end

  it "allows passing the personal information" do
    when_i_visit_the(
      :check_personal_information_page,
      application_id:,
      assessment_id:
    )
    then_i_see_the_personal_information

    when_i_choose_check_personal_information_yes
    then_i_see_the(:application_page, application_id:)
    and_i_see_check_personal_information_completed
  end

  it "allows failing the personal information" do
    when_i_visit_the(
      :check_personal_information_page,
      application_id:,
      assessment_id:
    )
    then_i_see_the_personal_information

    when_i_choose_check_personal_information_no
    then_i_see_the(:application_page, application_id:)
    and_i_see_check_personal_information_action_required
  end

  it "allows checking the qualifications" do
    when_i_visit_the(
      :check_qualifications_page,
      application_id:,
      assessment_id:
    )
    then_i_see_the_qualifications

    when_i_click_check_qualifications_continue
    then_i_see_the(:application_page, application_id:)
  end

  it "allows checking the work history" do
    when_i_visit_the(:check_work_history_page, application_id:, assessment_id:)
    then_i_see_the_work_history

    when_i_click_check_work_history_continue
    then_i_see_the(:application_page, application_id:)
  end

  it "allows checking the professional standing" do
    when_i_visit_the(
      :check_professional_standing_page,
      application_id:,
      assessment_id:
    )
    then_i_see_the_professional_standing

    when_i_click_check_professional_standing_continue
    then_i_see_the(:application_page, application_id:)
  end

  private

  def given_an_assessor_exists
    assessor
  end

  def given_there_is_an_application_form
    application_form
  end

  def then_i_see_the_personal_information
    expect(
      check_personal_information_page.personal_information.given_names.text
    ).to eq(application_form.given_names)
    expect(
      check_personal_information_page.personal_information.family_name.text
    ).to eq(application_form.family_name)
  end

  def when_i_choose_check_personal_information_yes
    check_personal_information_page.form.yes_radio_item.input.click
    check_personal_information_page.form.continue_button.click
  end

  def personal_information_task_item
    application_page.task_list.tasks.first.items.find do |item|
      item.link.text == "Check personal information"
    end
  end

  def and_i_see_check_personal_information_completed
    expect(personal_information_task_item.status).to have_content("COMPLETED")
  end

  def when_i_choose_check_personal_information_no
    check_personal_information_page.form.no_radio_item.input.click
    check_personal_information_page
      .form
      .failure_reason_checkbox_items
      .first
      .checkbox
      .click
    check_personal_information_page.form.continue_button.click
  end

  def and_i_see_check_personal_information_action_required
    expect(personal_information_task_item.status).to have_content(
      "ACTION REQUIRED"
    )
  end

  def then_i_see_the_qualifications
    teaching_qualification =
      application_form.qualifications.find(&:is_teaching_qualification?)
    expect(check_qualifications_page.teaching_qualification.title.text).to eq(
      teaching_qualification.title
    )
  end

  def then_i_see_the_work_history
    most_recent_role = application_form.work_histories.first
    expect(check_work_history_page.most_recent_role.school_name.text).to eq(
      most_recent_role.school_name
    )
  end

  def then_i_see_the_professional_standing
    expect(
      check_professional_standing_page
        .proof_of_recognition
        .reference_number
        .text
    ).to eq(application_form.registration_number)
  end

  def when_i_click_check_qualifications_continue
    check_qualifications_page.form.continue_button.click
  end

  def when_i_click_check_work_history_continue
    check_work_history_page.form.continue_button.click
  end

  def when_i_click_check_professional_standing_continue
    check_professional_standing_page.form.continue_button.click
  end

  def assessor
    @assessor ||= create(:staff, :confirmed)
  end

  def application_form
    @application_form ||=
      begin
        application_form =
          create(
            :application_form,
            :with_completed_qualification,
            :with_work_history,
            :with_registration_number,
            :with_personal_information,
            :submitted,
            :with_assessment
          )

        create(
          :assessment_section,
          :personal_information,
          assessment: application_form.assessment
        )
        create(
          :assessment_section,
          :qualifications,
          assessment: application_form.assessment
        )
        create(
          :assessment_section,
          :work_history,
          assessment: application_form.assessment
        )
        create(
          :assessment_section,
          :professional_standing,
          assessment: application_form.assessment
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
