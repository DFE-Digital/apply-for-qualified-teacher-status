# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assigning an assessor", type: :system do
  it "assigns an assessor" do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user(assessor)
    given_there_is_an_application_form
    given_an_assessor_exists

    when_i_visit_the_assign_assessor_page
    and_i_select_an_assessor
    then_the_assessor_is_assigned_to_the_application_form
  end

  private

  def given_there_is_an_application_form
    application_form
  end

  def given_an_assessor_exists
    assessor
  end

  def when_i_visit_the_assign_assessor_page
    visit assessor_interface_application_form_assign_assessor_path(
            application_form
          )
  end

  def and_i_select_an_assessor
    choose assessor.name, visible: false
    click_button "Continue"
  end

  def then_the_assessor_is_assigned_to_the_application_form
    expect(page).to have_content("Assigned to\t#{assessor.name}")
  end

  def application_form
    @application_form ||=
      create(:application_form, :with_personal_information, :submitted)
  end

  def assessor
    @assessor ||= create(:staff, :confirmed)
  end
end
