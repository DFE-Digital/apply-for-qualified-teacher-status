require "rails_helper"

RSpec.describe "Teacher application check answers", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_a_user(teacher)
    given_there_is_an_application_form

    when_i_visit_the(:teacher_check_your_answers_page, application_form_id:)
  end

  it "about you section" do
    when_i_click_change_links(:about_you, :personal_information) do
      and_i_click_continue
      then_i_see_the(:teacher_check_your_answers_page)
    end

    when_i_click_change_links(:about_you, :identification_document) do
      and_i_dont_need_to_upload_another_file
      then_i_see_the(:teacher_check_your_answers_page)
    end
  end

  it "who you can teach section" do
    when_i_click_change_links(:who_you_can_teach, :qualification) do
      if teacher_check_document_page.displayed?(0)
        and_i_dont_need_to_upload_another_file
      else
        and_i_click_continue
      end

      then_i_see_the(:teacher_check_your_answers_page)
    end

    when_i_click_change_links(:who_you_can_teach, :age_range) do
      and_i_click_continue
      then_i_see_the(:teacher_check_your_answers_page)
    end

    when_i_click_change_links(:who_you_can_teach, :subjects) do
      and_i_click_continue
      then_i_see_the(:teacher_check_your_answers_page)
    end
  end

  it "work history section" do
    when_i_click_change_links(:work_history, :work_history) do
      if teacher_check_document_page.displayed?(0)
        and_i_dont_need_to_upload_another_file
      else
        and_i_click_continue
      end

      then_i_see_the(:teacher_check_your_answers_page)
    end
  end

  it "proof of recognition section" do
    when_i_click_change_links(:proof_of_recognition, :registration_number) do
      and_i_click_continue
      then_i_see_the(:teacher_check_your_answers_page)
    end

    when_i_click_change_links(:proof_of_recognition, :written_statement) do
      and_i_dont_need_to_upload_another_file
      then_i_see_the(:teacher_check_your_answers_page)
    end
  end

  it "display application form work history before qualifications banner" do
    #should display the banner
    when_i_visit_the(:teacher_check_your_answers_page, application_form_id:) do
      and_i_have_early_work_history
      then_i_see_the_banner
    end

    #should not display the banner
    when_i_visit_the(:teacher_check_your_answers_page, application_form_id:) do
      and_i_have_later_work_history
      then_i_do_not_see_the_banner
    end

    #should not display the banner
    when_i_visit_the(:teacher_check_your_answers_page, application_form_id:) do
      and_i_have_no_work_history
      then_i_do_not_see_the_banner
    end

    #should not display the banner
    when_i_visit_the(:teacher_check_your_answers_page, application_form_id:) do
      and_i_have_no_qualifications
      then_i_do_not_see_the_banner
    end
  end

  def given_there_is_an_application_form
    application_form
  end

  def and_i_have_early_work_history
    application_form.work_histories.create!(start_date: Date.new(2022, 1, 1))
    application_form.qualifications.create!(
      certificate_date: Date.new(2023, 2, 1),
    )
  end

  def and_i_have_later_work_history
    application_form.work_histories.create!(start_date: Date.new(2023, 1, 1))
    application_form.qualifications.create!(
      certificate_date: Date.new(2022, 2, 1),
    )
  end

  def and_i_have_no_work_history
    application_form.work_histories.destroy_all
    application_form.qualifications.create!(
      certificate_date: Date.new(2022, 2, 1),
    )
  end

  def and_i_have_no_qualifications
    application_form.work_histories.create!(start_date: Date.new(2022, 1, 1))
    application_form.qualifications.destroy_all
  end

  def then_i_see_the_banner
    expect(page).to have_content(
      "You’ve added at least one teaching role that started before you were recognised as a qualified teacher.",
    )
  end

  def then_i_do_not_see_the_banner
    expect(page).not_to have_content(
      "You’ve added at least one teaching role that started before you were recognised as a qualified teacher.",
    )
  end

  def when_i_click_change_links(section, summary_list, &block)
    index = 0
    while (
            row =
              teacher_check_your_answers_page
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
    teacher_check_document_page.form.no_radio_item.input.click
    teacher_check_document_page.form.continue_button.click
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

  delegate :id, to: :application_form, prefix: true
end
