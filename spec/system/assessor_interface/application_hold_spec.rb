# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Putting application on hold", type: :system do
  before { given_there_is_an_application_form }

  it "does not allow any access if user is archived" do
    given_i_am_authorized_as_an_archived_assessor_user

    when_i_visit_the(:assessor_new_application_hold_page, reference:)
    then_i_see_the_forbidden_page
  end

  it "putting application on hold" do
    given_i_am_authorized_as_an_assessor_user

    when_i_visit_the(:assessor_application_page, reference:)
    then_i_see_the(:assessor_application_page, reference:)

    when_i_click_to_flag_application_as_on_hold
    then_i_see_the(:assessor_new_application_hold_page, reference:)

    when_i_select_reason_for_hold
    then_i_see_the(:assessor_new_confirm_application_hold_page, reference:)
    and_i_see_my_reason_for_hold

    when_i_confirm_my_selection
    then_i_see_the(:assessor_confirmation_application_hold_page, reference:)

    when_i_go_to_application_overview
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_the_option_to_remove_on_hold_flag
  end

  it "putting application on hold with 'Other' as reason" do
    given_i_am_authorized_as_an_assessor_user

    when_i_visit_the(:assessor_application_page, reference:)
    then_i_see_the(:assessor_application_page, reference:)

    when_i_click_to_flag_application_as_on_hold
    then_i_see_the(:assessor_new_application_hold_page, reference:)

    when_i_select_other_reason_for_hold
    then_i_see_the(:assessor_new_confirm_application_hold_page, reference:)
    and_i_see_my_reason_comment_for_hold

    when_i_confirm_my_selection
    then_i_see_the(:assessor_confirmation_application_hold_page, reference:)

    when_i_go_to_application_overview
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_the_option_to_remove_on_hold_flag
  end

  private

  def given_there_is_an_application_form
    application_form
  end

  def when_i_click_to_flag_application_as_on_hold
    click_on "Flag application as on hold"
  end

  def when_i_select_reason_for_hold
    assessor_new_application_hold_page.form.hold_reason_radio_items.first.choose
    assessor_new_application_hold_page.form.continue_button.click
  end

  def when_i_select_other_reason_for_hold
    assessor_new_application_hold_page.form.hold_reason_radio_items.last.choose
    expect(
      assessor_new_application_hold_page.form.hold_other_reason_comment_textarea,
    ).to be_visible
    assessor_new_application_hold_page.form.hold_other_reason_comment_textarea.fill_in with:
      "Needs custom hold reason."
    assessor_new_application_hold_page.form.continue_button.click
  end

  def and_i_see_my_reason_for_hold
    expect(assessor_new_confirm_application_hold_page).to have_content(
      "The application is being taken to Suitability Panel (a suitability concern has been highlighted)",
    )
  end

  def and_i_see_my_reason_comment_for_hold
    expect(assessor_new_confirm_application_hold_page).to have_content(
      "Needs custom hold reason.",
    )
  end

  def when_i_confirm_my_selection
    assessor_new_confirm_application_hold_page.form.submit_button.click
  end

  def when_i_go_to_application_overview
    click_on "See application overview"
  end

  def and_i_see_the_option_to_remove_on_hold_flag
    expect(assessor_application_page).to have_content("On hold")
    expect(assessor_application_page).to have_link("Remove on hold flag")
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :with_personal_information,
        :submitted,
        :with_assessment,
      )
  end

  delegate :reference, to: :application_form
end
