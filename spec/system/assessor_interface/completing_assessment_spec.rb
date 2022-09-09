# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor completing assessment", type: :system do
  it "completes an assessment" do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user(assessor)
    given_there_is_an_application_form

    when_i_visit_the(:complete_assessment_page, application_id:)

    when_i_select_award_qts
    and_i_click_continue
    then_the_application_form_is_awarded
  end

  private

  def given_there_is_an_application_form
    application_form
  end

  def when_i_visit_the_complete_assessment_page
    complete_assessment_page.load(application_id: application_form.id)
  end

  def then_i_see_the_complete_assessment_form
    expect(complete_assessment_page.award_qts).to be_visible
    expect(complete_assessment_page.decline_qts).to be_visible
  end

  def when_i_select_award_qts
    complete_assessment_page.award_qts.input.choose
  end

  def then_the_application_form_is_awarded
    expect(application_page.overview.status.text).to eq("AWARDED")
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :with_personal_information,
        :submitted,
        :with_assessment
      )
  end

  def application_id
    application_form.id
  end

  def assessor
    @assessor ||= create(:staff, :confirmed)
  end
end
