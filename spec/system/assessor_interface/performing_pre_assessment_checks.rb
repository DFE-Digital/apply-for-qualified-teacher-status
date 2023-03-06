# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor performing pre-assessment checks", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_professional_standing_request
  end

  it "preliminary check required" do
    when_i_visit_the(:assessor_application_page, application_id:)
    and_i_see_a_waiting_on_status
    and_i_see_an_unstarted_preliminary_check_task
    when_i_click_on_the_preliminary_check_task
    and_i_choose_yes_to_progress_the_application
    then_i_see_the(:assessor_application_page, application_id:)
    and_i_see_a_completed_preliminary_check_task
  end

  private

  def given_there_is_an_application_form_with_professional_standing_request
    application_form
  end

  def and_i_see_a_waiting_on_status
    expect(assessor_application_page.overview.status.text).to eq(
      "PRELIMINARY CHECK",
    )
  end

  def and_i_see_an_unstarted_preliminary_check_task
    expect(assessor_application_page.task_list).to have_content(
      "Preliminary check",
    )
    expect(assessor_application_page.preliminary_check_task).to have_content(
      "NOT STARTED",
    )
    expect(
      assessor_application_page.awaiting_professional_standing_task,
    ).to have_content("CANNOT START")
  end

  def when_i_click_on_the_preliminary_check_task
    assessor_application_page.preliminary_check_task.click
  end

  def and_i_choose_yes_to_progress_the_application
    preliminary_check_page.form.yes_radio_item.choose
    preliminary_check_page.form.continue_button.click
  end

  def and_i_see_a_completed_preliminary_check_task
    expect(assessor_application_page.preliminary_check_task).to have_content(
      "COMPLETED",
    )
    expect(
      assessor_application_page.awaiting_professional_standing_task,
    ).to have_content("WAITING ON")
  end

  def application_form
    @application_form ||=
      begin
        application_form = create(:application_form, :preliminary_check)
        create(
          :assessment,
          :with_professional_standing_request,
          application_form:,
        )
        application_form.region.update!(
          requires_preliminary_check: true,
          teaching_authority_provides_written_statement: true,
        )
        application_form
      end
  end

  def application_id
    application_form.id
  end
end
