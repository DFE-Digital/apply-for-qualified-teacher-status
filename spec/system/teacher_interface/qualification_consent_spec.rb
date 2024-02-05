require "rails_helper"

RSpec.describe "Teacher qualification consent", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_a_user(teacher)
    given_there_is_an_application_form
    given_there_is_a_qualification_request
  end

  it "save and sign out" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_qualification_consent_content
  end

  it "check your answers" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_qualification_consent_content
  end

  def given_there_is_an_application_form
    application_form
  end

  def given_there_is_a_qualification_request
    qualification_request
  end

  def and_i_see_qualification_consent_content
    expect(teacher_application_page).to have_content(
      "We need your written consent to verify some of your qualifications",
    )
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :submitted,
        :with_assessment,
        :with_teaching_qualification,
        statuses: %w[waiting_on_qualification],
        teacher:,
      )
  end

  def qualification_request
    @qualification_request ||=
      create(
        :qualification_request,
        :consent_requested,
        assessment: application_form.assessment,
      )
  end
end
