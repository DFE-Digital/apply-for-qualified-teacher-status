# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor requesting further information", type: :system do
  it "completes an assessment" do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user(assessor)
    given_there_is_an_application_form_with_failure_reasons

    when_i_visit_the(:complete_assessment_page, application_id:, assessment_id:)

    when_i_select_request_further_information
    and_i_click_continue
    then_i_see_the(
      :request_further_information_page,
      application_id:,
      assessment_id:,
    )

    when_i_click_continue
    then_i_see_the(
      :further_information_request_preview_page,
      application_id:,
      assessment_id:,
      further_information_request_id:,
    )
  end

  private

  def given_there_is_an_application_form_with_failure_reasons
    application_form
  end

  def when_i_visit_the_complete_assessment_page
    complete_assessment_page.load(application_id: application_form.id)
  end

  def then_i_see_the_complete_assessment_form
    expect(complete_assessment_page.award_qts).to be_visible
    expect(complete_assessment_page.decline_qts).to be_visible
  end

  def when_i_select_request_further_information
    complete_assessment_page.request_further_information.input.choose
  end

  def then_the_application_form_is_awarded
    expect(assessor_application_page.overview.status.text).to eq("AWARDED")
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
          :personal_information,
          :failed,
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
