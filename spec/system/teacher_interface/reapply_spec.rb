# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher reapply", type: :system do
  before do
    given_i_am_authorized_as_a_user(teacher)
    given_there_is_an_application_form
  end

  it "allows reapplying" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_declined_application_page)

    when_i_click_apply_again
    then_i_see_the(:teacher_new_application_page)
    and_i_see_the_reapply_warning

    when_i_click_continue
    then_i_see_the(:teacher_application_page)
  end

  def given_there_is_an_application_form
    application_form
  end

  def when_i_click_apply_again
    teacher_declined_application_page.apply_again_button.click
  end

  def and_i_see_the_reapply_warning
    expect(teacher_new_application_page).to have_content(
      "If you reapply for QTS, you will not be able to review the details of your previous application.",
    )
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :declined,
        teacher:,
        region: create(:region, :national),
        assessment: create(:assessment),
      )
  end
end
