# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor listing application forms", type: :system do
  it "displays a list of applications" do
    given_the_service_is_staff_http_basic_auth
    given_there_are_application_forms

    when_i_am_authorized_as_an_assessor_user
    when_i_visit_the_applications_page
    then_i_see_a_list_of_applications
  end

  private

  def given_the_service_is_staff_http_basic_auth
    FeatureFlag.activate(:staff_http_basic_auth)
  end

  def given_there_are_application_forms
    application_forms
  end

  def when_i_visit_the_applications_page
    visit assessor_interface_application_forms_path
  end

  def then_i_see_a_list_of_applications
    application_forms.each do |application_form|
      expect(page).to have_content(
        "#{application_form.given_names} #{application_form.family_name}"
      )
    end
  end

  def application_forms
    @application_forms ||=
      create_list(:application_form, 3, :with_personal_information, :submitted)
  end
end
