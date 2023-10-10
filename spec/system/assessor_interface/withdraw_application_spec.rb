# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor withdraw application", type: :system do
  before do
    given_the_service_is_open
    given_there_is_an_application_form
  end

  it "checks manage applications permission" do
    given_i_am_authorized_as_a_user(assessor)

    when_i_visit_the(
      :assessor_reverse_decision_page,
      application_form_id:,
      assessment_id:,
    )
    then_i_see_the_forbidden_page
  end

  it "allows withdrawing an application" do
    given_i_am_authorized_as_a_user(manager)

    when_i_visit_the(:assessor_application_page, application_id:)
    then_i_see_the(:assessor_application_page)
    and_i_see_the_withdraw_link

    when_i_click_on_withdraw
    then_i_see_the(:assessor_withdraw_application_page, application_form_id:)

    when_i_confirm_the_withdrawal
    then_i_see_the(:assessor_application_page, application_id:)
  end

  def given_there_is_an_application_form
    application_form
    assessment
  end

  def and_i_see_the_withdraw_link
    expect(assessor_application_page.management_tasks).to be_visible
  end

  def when_i_click_on_withdraw
    assessor_application_page.management_tasks.links.first.click
  end

  def when_i_confirm_the_withdrawal
    assessor_withdraw_application_page.form.submit_button.click
  end

  def application_form
    @application_form ||=
      create(:application_form, :declined, :with_personal_information)
  end

  delegate :id, to: :application_form, prefix: true
  alias_method :application_id, :application_form_id

  def assessment
    @assessment ||= create(:assessment, :decline, application_form:)
  end

  delegate :id, to: :assessment, prefix: true

  def assessor
    create(:staff, :confirmed, :with_assess_permission)
  end

  def manager
    create(:staff, :confirmed, :with_withdraw_permission)
  end
end
