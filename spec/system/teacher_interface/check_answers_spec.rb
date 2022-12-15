require "rails_helper"

RSpec.describe "Teacher application check answers", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_a_user(teacher)
    given_there_is_an_application_form

    when_i_visit_the(:check_your_answers_page, application_id:)
  end

  it "about you section" do
    when_i_click_change_links(:about_you, :personal_information) do
      and_i_click_continue
      then_i_see_the(:check_your_answers_page)
    end

    when_i_click_change_links(:about_you, :identification_document) do
      and_i_dont_need_to_upload_another_file
      then_i_see_the(:check_your_answers_page)
    end
  end

  it "who you can teach section" do
    when_i_click_change_links(:who_you_can_teach, :qualification) do
      if document_form_page.displayed?(0)
        and_i_dont_need_to_upload_another_file
      else
        and_i_click_continue
      end

      then_i_see_the(:check_your_answers_page)
    end

    when_i_click_change_links(:who_you_can_teach, :age_range) do
      and_i_click_continue
      then_i_see_the(:check_your_answers_page)
    end

    when_i_click_change_links(:who_you_can_teach, :subjects) do
      and_i_click_continue
      then_i_see_the(:check_your_answers_page)
    end
  end

  it "work history section" do
    when_i_click_change_links(:work_history, :add) do
      and_i_click_continue
      then_i_see_the(:check_your_answers_page)
    end

    when_i_click_change_links(:work_history, :work_history) do
      if document_form_page.displayed?(0)
        and_i_dont_need_to_upload_another_file
      else
        and_i_click_continue
      end

      then_i_see_the(:check_your_answers_page)
    end
  end

  it "proof of recognition section" do
    when_i_click_change_links(:proof_of_recognition, :registration_number) do
      and_i_click_continue
      then_i_see_the(:check_your_answers_page)
    end

    when_i_click_change_links(:proof_of_recognition, :written_statement) do
      and_i_dont_need_to_upload_another_file
      then_i_see_the(:check_your_answers_page)
    end
  end

  def given_there_is_an_application_form
    application_form
  end

  def when_i_click_change_links(section, summary_list, &block)
    index = 0
    while (
            row =
              check_your_answers_page
                .send(section)
                .send("#{summary_list}_summary_list")
                .rows[
                index
              ]
          )
      row.actions.link.click
      block.call
      index += 1
    end
  end

  def and_i_dont_need_to_upload_another_file
    document_form_page.form.no_radio_item.input.click
    document_form_page.form.continue_button.click
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :with_personal_information,
        :with_identification_document,
        :with_age_range,
        :with_subjects,
        :with_registration_number,
        :with_work_history,
        :with_written_statement,
        :with_completed_qualification,
        teacher:,
      )
  end

  def application_id
    application_form.id
  end
end
