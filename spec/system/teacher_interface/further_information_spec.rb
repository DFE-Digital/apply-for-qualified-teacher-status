require "rails_helper"

RSpec.describe "Teacher further information", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_a_user(teacher)
    given_there_is_an_application_form
  end

  it "shows start page" do
    when_i_visit_the(:further_information_requested_start_page)
    then_i_see_the(:further_information_requested_start_page)
  end

  def given_there_is_an_application_form
    application_form
  end

  def teacher
    @teacher ||= create(:teacher, :confirmed)
  end

  def application_form
    @application_form ||=
      create(:application_form, :further_information_requested, teacher:)
  end
end
