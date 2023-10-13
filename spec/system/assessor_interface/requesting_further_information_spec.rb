# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor requesting further information", type: :system do
  let(:notify_key) { "notify-key" }
  let(:notify_client) do
    double(generate_template_preview: notify_template_preview)
  end
  let(:notify_template_preview) { double(html: "I am an email") }

  around do |example|
    ClimateControl.modify GOVUK_NOTIFY_API_KEY: notify_key do
      example.run
    end
  end

  before do
    allow(Notifications::Client).to receive(:new).with(notify_key).and_return(
      notify_client,
    )
  end

  it "completes an assessment" do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_failure_reasons

    when_i_visit_the(
      :assessor_complete_assessment_page,
      application_id:,
      assessment_id:,
    )

    when_i_select_request_further_information
    and_i_click_continue
    then_i_see_the(
      :assessor_request_further_information_page,
      application_id:,
      assessment_id:,
    )
    and_i_see_the_further_information_request_items

    when_i_click_continue_to_email_button
    then_i_see_the(
      :assessor_further_information_request_preview_page,
      application_id:,
      assessment_id:,
    )
    and_i_see_the_email_preview

    when_i_click_send_to_applicant
    then_i_see_the(
      :assessor_further_information_request_page,
      application_id:,
      assessment_id:,
      further_information_request_id:,
    )
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
    expect(
      assessor_request_further_information_page.items.first.heading.text,
    ).to eq(
      "Subjects entered are acceptable for QTS, but the uploaded qualifications do not match them.",
    )
    expect(
      assessor_request_further_information_page.items.first.feedback.text,
    ).to eq("A note.")
  end

  def when_i_click_continue_to_email_button
    assessor_request_further_information_page.continue_button.click
  end

  def and_i_see_the_email_preview
    expect(
      assessor_further_information_request_preview_page.email_preview,
    ).to have_content("I am an email")
  end

  def when_i_click_send_to_applicant
    assessor_further_information_request_preview_page
      .form
      .send_to_applicant_button
      .click
  end

  def and_i_receive_a_further_information_requested_email
    message = ActionMailer::Base.deliveries.last
    expect(message).to_not be_nil

    expect(message.subject).to eq(
      "We need some more information to progress your QTS application",
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

  def application_id
    application_form.id
  end

  def assessment_id
    application_form.assessment.id
  end

  def further_information_request_id
    FurtherInformationRequest.last.id
  end
end
