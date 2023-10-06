# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor reviewing verifications", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_failed_verifications
  end

  it "sends for review" do
    # TODO: review functionality is not built yet, this page can never be reached
    when_i_visit_the(
      :assessor_assessment_recommendation_review_page,
      application_form_id:,
      assessment_id:,
    )
    then_i_see_the(
      :assessor_application_page,
      application_id: application_form_id,
    )
  end

  private

  def given_there_is_an_application_form_with_failed_verifications
    application_form
  end

  def application_form
    @application_form ||=
      create(:application_form, :submitted).tap do |application_form|
        assessment = create(:assessment, :verify, application_form:)
        create(
          :professional_standing_request,
          :received,
          assessment:,
          verify_passed: false,
        )
      end
  end

  def application_form_id
    application_form.id
  end

  def assessment_id
    application_form.assessment.id
  end
end
