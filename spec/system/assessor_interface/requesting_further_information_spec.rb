# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor requesting further information", type: :system do
  it "completes an assessment" do
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_failure_reasons

    when_i_visit_the(
      :assessor_complete_assessment_page,
      reference:,
      assessment_id:,
    )

    when_i_select_request_further_information
    and_i_click_continue
    then_i_see_the(
      :assessor_request_further_information_page,
      reference:,
      assessment_id:,
    )
    and_i_see_the_further_information_request_items

    when_i_click_the_continue_button
    then_i_see_the(:assessor_application_status_page, reference:)
    and_i_receive_a_further_information_requested_email
  end

  private

  def given_there_is_an_application_form_with_failure_reasons
    application_form
  end

  def given_there_is_an_application_form_with_work_history_contact_failure_reasons
    application_form_for_work_history_contact
  end

  def when_i_select_request_further_information
    assessor_complete_assessment_page.request_further_information.input.choose
  end

  def and_i_see_the_further_information_request_items
    expect(assessor_request_further_information_page.items.count).to eq(1)
    expect(assessor_request_further_information_page).to have_content(
      "Subjects entered are acceptable for QTS, but the uploaded qualifications do not match them.",
    )
    expect(
      assessor_request_further_information_page.items.first.feedback.text,
    ).to eq("A note.")
  end

  def when_i_click_the_continue_button
    assessor_request_further_information_page.continue_button.click
  end

  def and_i_receive_a_further_information_requested_email
    message = ActionMailer::Base.deliveries.last
    expect(message).not_to be_nil

    expect(message.subject).to eq(
      "Your QTS application: More information needed",
    )
    expect(message.to).to include(application_form.teacher.email)
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :with_personal_information,
        :assessment_in_progress,
        :with_assessment,
      ).tap do |application_form|
        application_form.assessment.sections << create(
          :assessment_section,
          :qualifications,
          :failed,
          selected_failure_reasons: [
            build(
              :selected_failure_reason,
              key: "qualifications_dont_match_subjects",
              assessor_feedback: "A note.",
            ),
          ],
        )
      end
  end

  def application_form_for_work_history_contact
    @application_form_for_work_history_contact ||=
      create(
        :application_form,
        :with_personal_information,
        :assessment_in_progress,
        :with_assessment,
      ).tap do |application_form|
        application_form.assessment.sections << create(
          :assessment_section,
          :qualifications,
          :failed,
          selected_failure_reasons: [
            build(
              :selected_failure_reasons,
              key: "school_details_cannot_be_verified",
              assessor_feedback: {
                note: "A note.",
                contact_name: "james",
                contact_job: "teacher",
                contact_email: "email@sample.com",
              },
            ),
          ],
        )
      end
  end

  delegate :reference, to: :application_form

  def assessment_id
    application_form.assessment.id
  end
end
