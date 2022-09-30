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
    given_i_am_authorized_as_a_user(assessor)
    given_there_is_an_application_form_with_failure_reasons

    when_i_visit_the(:complete_assessment_page, application_id:, assessment_id:)

    when_i_select_request_further_information
    and_i_click_continue
    then_i_see_the(
      :request_further_information_page,
      application_id:,
      assessment_id:,
    )
    and_i_see_the_further_information_request_items

    when_i_enter_email_content
    and_i_click_continue
    then_i_see_the(
      :further_information_request_preview_page,
      application_id:,
      assessment_id:,
      further_information_request_id:,
    )
    and_i_see_the_email_preview
  end

  private

  def given_there_is_an_application_form_with_failure_reasons
    application_form
  end

  def when_i_select_request_further_information
    complete_assessment_page.request_further_information.input.choose
  end

  def and_i_see_the_further_information_request_items
    expect(request_further_information_page.items.count).to eq(1)
    expect(request_further_information_page.items.first.heading.text).to eq(
      "The qualifications do not support the teaching subjects entered.",
    )
    expect(
      request_further_information_page.items.first.assessor_notes.text,
    ).to eq("A note.")
  end

  def when_i_enter_email_content
    request_further_information_page.form.email_content_textarea.fill_in with:
      "I am an email"
  end

  def and_i_see_the_email_preview
    expect(
      further_information_request_preview_page.email_preview,
    ).to have_content("I am an email")
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :with_personal_information,
        :submitted,
        :with_assessment,
      ).tap do |application_form|
        application_form.assessment.sections << create(
          :assessment_section,
          :qualifications,
          :failed,
          selected_failure_reasons: {
            qualifications_dont_support_subjects: "A note.",
          },
        )
      end
  end

  def application_id
    application_form.id
  end

  def assessment_id
    application_form.assessment.id
  end

  def assessor
    @assessor ||= create(:staff, :confirmed)
  end

  def further_information_request_id
    FurtherInformationRequest.last.id
  end
end
