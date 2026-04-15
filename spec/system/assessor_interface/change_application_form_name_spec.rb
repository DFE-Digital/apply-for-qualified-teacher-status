# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor change application form name", type: :system do
  before { given_there_is_an_application_form }

  context "when user does not have edit name permission" do
    before { given_i_am_authorized_as_a_user(assessor) }

    it "checks manage applications permission" do
      when_i_visit_the(:assessor_edit_application_name_page, reference:)
      then_i_see_the_forbidden_page
    end

    it "does not show change name link on overview page" do
      when_i_visit_the(:assessor_application_page, reference:)
      then_i_see_the(:assessor_application_page)
      expect(
        assessor_application_page.summary_list.find_row(key: "Name"),
      ).to have_no_actions
    end

    it "does not show change name link on personal information page" do
      when_i_visit_the(
        :assessor_check_personal_information_page,
        reference:,
        assessment_id:,
        section_id: section_id("personal_information"),
      )
      then_i_see_the(:assessor_check_personal_information_page)
      expect(
        assessor_check_personal_information_page.summary_list.find_row(
          key: "Given names",
        ),
      ).to have_no_actions
      expect(
        assessor_check_personal_information_page.summary_list.find_row(
          key: "Surname",
        ),
      ).to have_no_actions
    end

    it "does not allow any access if user is archived" do
      given_i_am_authorized_as_an_archived_user(manager)

      when_i_visit_the(:assessor_edit_application_name_page, reference:)
      then_i_see_the_forbidden_page
    end
  end

  context "when user has edit name permission" do
    before { given_i_am_authorized_as_a_user(manager) }

    it "allows changing application form name" do
      when_i_visit_the(:assessor_application_page, reference:)
      then_i_see_the(:assessor_application_page)

      when_i_click_on_change_name
      then_i_see_the(:assessor_edit_application_name_page, reference:)

      when_i_fill_in_the_name
      then_i_see_the(:assessor_application_page, reference:)
    end

    it "shows change name link on personal information page" do
      when_i_visit_the(
        :assessor_check_personal_information_page,
        reference:,
        assessment_id:,
        section_id: section_id("personal_information"),
      )
      then_i_see_the(:assessor_check_personal_information_page)
      expect(
        assessor_check_personal_information_page.summary_list.find_row(
          key: "Given names",
        ),
      ).to have_actions
      expect(
        assessor_check_personal_information_page.summary_list.find_row(
          key: "Surname",
        ),
      ).to have_actions

      when_i_click_on_change_given_names
      then_i_see_the(:assessor_edit_application_name_page, reference:)

      # TODO: uncomment when back link bug is fixed
      # when_i_click_the_back_link
      #
      # when_i_click_on_change_surname
      # then_i_see_the(:assessor_edit_application_name_page, reference:)
    end
  end

  def given_there_is_an_application_form
    application_form
  end

  def when_i_click_on_change_name
    assessor_application_page
      .summary_list
      .find_row(key: "Name")
      .actions
      .link
      .click
  end

  def when_i_click_on_change_given_names
    assessor_check_personal_information_page
      .summary_list
      .find_row(key: "Given names")
      .actions
      .link
      .click
  end

  def when_i_click_on_change_surname
    assessor_check_personal_information_page
      .summary_list
      .find_row(key: "Surname")
      .actions
      .link
      .click
  end

  def when_i_fill_in_the_name
    assessor_edit_application_name_page.form.given_names_field.fill_in with:
      "New given names"
    assessor_edit_application_name_page.form.family_name_field.fill_in with:
      "New family name"
    assessor_edit_application_name_page.form.submit_button.click
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

  def when_i_click_the_back_link
    assessor_check_personal_information_page.back_link.click
  end
end
