require "rails_helper"

RSpec.describe "Assessor views duplicate applicant's application form",
               type: :system do
  it "displays information about the duplicate applicant" do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form
    and_the_applicant_matches_a_record_in_dqt

    when_i_visit_the(:assessor_application_page, application_id:)
    then_i_see_the_application
    and_i_see_the_warning_of_an_existing_record_in_dqt
  end

  private

  def given_there_is_an_application_form
    application_form
  end

  def when_i_click_back_link
    assessor_application_page.back_link.click
  end

  def then_i_see_the_application
    expect(assessor_application_page.overview.name.text).to eq(
      "#{application_form.given_names} #{application_form.family_name}",
    )
  end

  def and_i_see_the_warning_of_an_existing_record_in_dqt
    expect(assessor_application_page).to have_content(
      "The application details match a record in DQT",
    )
    expect(assessor_application_page).to have_content(
      "Teacher Reference Number: 7654322",
    )
  end

  def and_the_applicant_matches_a_record_in_dqt
    application_form.update!(dqt_match:)
  end

  def application_form
    @application_form ||=
      begin
        application_form =
          create(
            :application_form,
            :with_personal_information,
            :submitted,
            :with_assessment,
          )

        create(
          :assessment_section,
          :personal_information,
          assessment: application_form.assessment,
        )

        application_form
      end
  end

  def application_id
    application_form.id
  end

  def dqt_match
    {
      "firstName" => application_form.given_names,
      "lastName" => application_form.family_name,
      "dateOfBirth" => application_form.date_of_birth.iso8601.to_s,
      "trn" => "7654322",
    }
  end
end