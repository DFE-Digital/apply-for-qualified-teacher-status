# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor views duplicate applicant's application form",
               type: :system do
  it "displays information about the duplicate applicant" do
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form
    and_the_applicant_matches_a_record_in_dqt

    when_i_visit_the(:assessor_application_page, reference:)
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
    expect(assessor_application_page.name_summary.value).to have_text(
      "#{application_form.given_names} #{application_form.family_name}",
    )
  end

  def and_i_see_the_warning_of_an_existing_record_in_dqt
    expect(assessor_application_page).to have_content(
      "Application details match DQT record(s)",
    )
    expect(assessor_application_page).to have_content("John Smith, TRN 7654322")
  end

  def and_the_applicant_matches_a_record_in_dqt
    application_form.update!(trs_match:)
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

  delegate :reference, to: :application_form

  def trs_match
    {
      "first_name" => "John",
      "last_name" => "Smith",
      "date_of_birth" => application_form.date_of_birth.iso8601.to_s,
      "trn" => "7654322",
    }
  end
end
