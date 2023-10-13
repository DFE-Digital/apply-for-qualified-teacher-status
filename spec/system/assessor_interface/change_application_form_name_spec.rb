# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor change application form name", type: :system do
  before do
    given_the_service_is_open
    given_there_is_an_application_form
  end

  it "checks manage applications permission" do
    given_i_am_authorized_as_a_user(assessor)

    when_i_visit_the(:assessor_edit_application_page, application_form_id:)
    then_i_see_the_forbidden_page
  end

  it "allows changing application form name" do
    given_i_am_authorized_as_a_user(manager)

    when_i_visit_the(:assessor_application_page, application_form_id:)
    then_i_see_the(:assessor_application_page)

    when_i_click_on_change_name
    then_i_see_the(:assessor_edit_application_page, application_form_id:)

    when_i_fill_in_the_name
    then_i_see_the(:assessor_application_page, application_form_id:)
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

  delegate :id, to: :application_form, prefix: true

  def assessor
    create(:staff, :confirmed, :with_assess_permission)
  end

  def manager
    create(:staff, :confirmed, :with_change_name_permission)
  end
end
