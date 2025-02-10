# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher application view answers", type: :system do
  let(:teacher) { create(:teacher) }
  let(:application_form) do
    create(
      :application_form,
      :with_personal_information,
      :with_identification_document,
      :with_age_range,
      :with_subjects,
      :with_registration_number,
      :with_work_history,
      :with_written_statement,
      :with_teaching_qualification,
      :submitted,
      teacher:,
    )
  end

  it "shows all the sections" do
    given_i_am_authorized_as_a_user(teacher)
    given_there_is_an_application_form

    when_i_visit_the(:teacher_view_answers_page)

    then_i_see_the_view_your_answers_title
    and_i_see_about_you_summary
    and_i_see_who_you_can_teach_summary
    and_i_see_your_english_proficiency_summary
    and_i_see_your_work_history_summary
    and_i_see_your_proof_of_recognition_summary
  end

  context "when the applicant has uploaded passport to prove identity" do
    let(:application_form) do
      create(
        :application_form,
        :with_personal_information,
        :with_passport_document,
        :with_age_range,
        :with_subjects,
        :with_registration_number,
        :with_work_history,
        :with_written_statement,
        :with_teaching_qualification,
        :submitted,
        teacher:,
        requires_passport_as_identity_proof: true,
      )
    end

    it "shows passport document summary instead of identity document" do
      given_i_am_authorized_as_a_user(teacher)
      given_there_is_an_application_form

      when_i_visit_the(:teacher_view_answers_page)

      then_i_see_the_upload_your_passport_instead_of_identity
    end
  end

  def then_i_see_the_view_your_answers_title
    expect(teacher_view_answers_page.heading).to have_content(
      "View the answers you submitted to us",
    )
  end

  def and_i_see_about_you_summary
    expect(teacher_view_answers_page.about_you).to be_present
    expect(
      teacher_view_answers_page.about_you.personal_information_summary_list,
    ).to be_present
    expect(
      teacher_view_answers_page.about_you.identification_document_summary_list,
    ).to be_present
  end

  def then_i_see_the_upload_your_passport_instead_of_identity
    expect(teacher_view_answers_page.about_you).to be_present
    expect(
      teacher_view_answers_page.about_you.personal_information_summary_list,
    ).to be_present
    expect(
      teacher_view_answers_page.about_you.passport_document_summary_list,
    ).to be_present

    expect(teacher_view_answers_page.about_you).to have_content(
      "Upload your passport",
    )
    expect(teacher_view_answers_page.about_you).not_to have_content(
      "Upload your identity document",
    )
  end

  def and_i_see_who_you_can_teach_summary
    expect(teacher_view_answers_page.who_you_can_teach).to be_present
    expect(
      teacher_view_answers_page.who_you_can_teach.qualification_summary_lists,
    ).to be_present
    expect(
      teacher_view_answers_page.who_you_can_teach.age_range_summary_list,
    ).to be_present
    expect(
      teacher_view_answers_page.who_you_can_teach.subjects_summary_list,
    ).to be_present
  end

  def and_i_see_your_english_proficiency_summary
    expect(
      teacher_view_answers_page.your_english_language_proficiency,
    ).to be_present
  end

  def and_i_see_your_work_history_summary
    expect(teacher_view_answers_page.work_history).to be_present
  end

  def and_i_see_your_proof_of_recognition_summary
    expect(teacher_view_answers_page.proof_of_recognition).to be_present
    expect(
      teacher_view_answers_page.proof_of_recognition.registration_number_summary_list,
    ).to be_present
    expect(
      teacher_view_answers_page.proof_of_recognition.written_statement_summary_list,
    ).to be_present
  end

  def given_there_is_an_application_form
    application_form
  end
end
