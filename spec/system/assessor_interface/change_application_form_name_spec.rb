# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor change application form name", type: :system do
  before { given_there_is_an_application_form }

  it "checks manage applications permission" do
    given_i_am_authorized_as_a_user(assessor)

    when_i_visit_the(:assessor_edit_application_page, reference:)
    then_i_see_the_forbidden_page
  end

  it "allows changing application form name" do
    given_i_am_authorized_as_a_user(manager)

    when_i_visit_the(:assessor_application_page, reference:)
    then_i_see_the(:assessor_application_page)

    when_i_click_on_change_name
    then_i_see_the(:assessor_edit_application_page, reference:)

    when_i_fill_in_the_name
    then_i_see_the(:assessor_application_page, reference:)
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

  def when_i_fill_in_the_name
    assessor_edit_application_page.form.given_names_field.fill_in with:
      "New given names"
    assessor_edit_application_page.form.family_name_field.fill_in with:
      "New family name"
    assessor_edit_application_page.form.submit_button.click
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :submitted,
        :with_personal_information,
        :with_assessment,
      )
  end

  delegate :reference, to: :application_form

  def assessor
    create(:staff, :confirmed, :with_assess_permission)
  end

  def manager
    create(:staff, :confirmed, :with_change_name_permission)
  end
end
