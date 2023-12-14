# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor reverse decision", type: :system do
  before { given_there_is_an_application_form }

  it "checks manage applications permission" do
    given_i_am_authorized_as_a_user(assessor)

    when_i_visit_the(
      :assessor_reverse_decision_page,
      reference:,
      assessment_id:,
    )
    then_i_see_the_forbidden_page
  end

  it "allows reversing a decision" do
    given_i_am_authorized_as_a_user(manager)

    when_i_visit_the(:assessor_application_page, reference:)
    then_i_see_the(:assessor_application_page)
    and_i_see_the_reverse_decision_link

    when_i_click_on_reverse_decision
    then_i_see_the(:assessor_reverse_decision_page, reference:, assessment_id:)

    when_i_confirm_the_reversal
    then_i_see_the(:assessor_application_page, reference:)
  end

  def given_there_is_an_application_form
    application_form
    assessment
  end

  def and_i_see_the_reverse_decision_link
    expect(assessor_application_page.task_lists.last).to have_content(
      "Reverse decision",
    )
  end

  def when_i_click_on_reverse_decision
    assessor_application_page.task_lists.last.click_on("Reverse decision")
  end

  def when_i_confirm_the_reversal
    assessor_reverse_decision_page.form.submit_button.click
  end

  def application_form
    @application_form ||=
      create(:application_form, :declined, :with_personal_information)
  end

  delegate :reference, to: :application_form

  def assessment
    @assessment ||= create(:assessment, :decline, application_form:)
  end

  delegate :id, to: :assessment, prefix: true

  def assessor
    create(:staff, :with_assess_permission)
  end

  def manager
    create(:staff, :with_reverse_decision_permission)
  end
end
