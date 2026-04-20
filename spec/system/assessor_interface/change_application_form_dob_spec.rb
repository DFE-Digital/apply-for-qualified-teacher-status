# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor change application form date of birth",
               type: :system do
  before { given_there_is_an_application_form }

  context "when user does not have edit name permission" do
    before { given_i_am_authorized_as_a_user(assessor) }

    it "checks manage applications permission" do
      when_i_visit_the(:assessor_edit_application_name_page, reference:)
      then_i_see_the_forbidden_page
    end

    it "does not show change date of birth link on personal information page" do
      when_i_visit_the(
        :assessor_check_personal_information_page,
        reference:,
        assessment_id:,
        section_id: section_id("personal_information"),
      )
      then_i_see_the(:assessor_check_personal_information_page)
      expect(
        assessor_check_personal_information_page.summary_list.find_row(
          key: "Date of birth",
        ),
      ).to have_no_actions
    end
  end

  context "when user has edit name permission" do
    before { given_i_am_authorized_as_a_user(manager) }

    it "does not allow any access if user is archived" do
      given_i_am_authorized_as_an_archived_user(manager)

      when_i_visit_the(
        :assessor_edit_application_date_of_birth_page,
        reference:,
      )
      then_i_see_the_forbidden_page
    end

    it "allows changing application form date of birth" do
      when_i_visit_the(
        :assessor_check_personal_information_page,
        reference:,
        assessment_id:,
        section_id: section_id("personal_information"),
      )
      then_i_see_the(:assessor_check_personal_information_page)
      expect(
        assessor_check_personal_information_page.summary_list.find_row(
          key: "Date of birth",
        ),
      ).to have_actions

      when_i_click_on_change_date_of_birth
      then_i_see_the(:assessor_edit_application_date_of_birth_page, reference:)

      when_i_fill_in_the_date_of_birth
      then_i_see_the(:assessor_application_page, reference:)
    end
  end

  private

  def given_there_is_an_application_form
    application_form
  end

  def application_form
    @application_form ||=
      begin
        form =
          create(
            :application_form,
            :submitted,
            :with_personal_information,
            :with_assessment,
          )
        create(
          :assessment_section,
          :personal_information,
          assessment: form.assessment,
        )
        form
      end
  end

  delegate :reference, to: :application_form

  def assessment_id
    application_form.assessment.id
  end

  def section_id(key)
    application_form.assessment.sections.find_by(key:).id
  end

  def assessor
    create(:staff, :with_assess_permission)
  end

  def manager
    create(:staff, :with_change_name_permission)
  end

  def when_i_click_on_change_date_of_birth
    assessor_check_personal_information_page
      .summary_list
      .find_row(key: "Date of birth")
      .actions
      .link
      .click
  end

  def when_i_fill_in_the_date_of_birth
    assessor_edit_application_date_of_birth_page.form.day_field.fill_in with:
      "1"
    assessor_edit_application_date_of_birth_page.form.month_field.fill_in with:
      "1"
    assessor_edit_application_date_of_birth_page.form.year_field.fill_in with:
      "1990"
    assessor_edit_application_date_of_birth_page.form.submit_button.click
  end
end
