require "rails_helper"

RSpec.describe "Assessor view application form", type: :system do
  it "displays the application overview" do
    given_the_service_is_staff_http_basic_auth
    given_there_is_an_application_form

    when_i_am_authorized_as_an_assessor_user
    when_i_visit_the_application_page
    then_i_see_the_application
  end

  private

  def given_the_service_is_staff_http_basic_auth
    FeatureFlag.activate(:staff_http_basic_auth)
  end

  def given_there_is_an_application_form
    application_form
  end

  def when_i_visit_the_application_page
    visit assessor_interface_application_form_path(application_form)
  end

  def then_i_see_the_application
    expect(page).to have_content(
      "#{application_form.given_names} #{application_form.family_name}"
    )
    expect(page).to have_content(application_form.reference)
  end

  def application_form
    @application_form ||= create(:application_form, :with_personal_information)
  end
end
