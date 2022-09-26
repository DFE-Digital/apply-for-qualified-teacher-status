require "rails_helper"

RSpec.describe "Teacher further information", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_a_user(teacher)
    given_there_is_an_application_form
  end

  it "shows start page" do
    when_i_visit_the(:further_information_requested_start_page)
    then_i_see_the(:further_information_requested_start_page)

    when_i_click_the_start_button
    then_i_see_the(:further_information_requested_page)
    and_i_see_the_text_task_list_item
    and_i_see_the_document_task_list_item

    when_i_click_the_save_and_sign_out_button
    then_i_see_the(:signed_out_page)
  end

  def given_there_is_an_application_form
    application_form
  end

  def when_i_click_the_start_button
    further_information_requested_start_page.start_button.click
  end

  def and_i_see_the_text_task_list_item
    item =
      further_information_requested_page.task_list.sections.first.items.first
    expect(item.link.text).to eq("Text")
    expect(item.status_tag.text).to eq("NOT STARTED")
  end

  def and_i_see_the_document_task_list_item
    item =
      further_information_requested_page.task_list.sections.first.items.second
    expect(item.link.text).to eq("Document")
    expect(item.status_tag.text).to eq("NOT STARTED")
  end

  def when_i_click_the_save_and_sign_out_button
    further_information_requested_page.save_and_sign_out_button.click
  end

  def teacher
    @teacher ||= create(:teacher, :confirmed)
  end

  def application_form
    @application_form ||=
      begin
        application_form =
          create(:application_form, :further_information_requested, teacher:)
        request = application_form.assessment.further_information_requests.first
        create(
          :further_information_request_item,
          :with_text_response,
          further_information_request: request,
        )
        create(
          :further_information_request_item,
          :with_document_response,
          further_information_request: request,
        )
        application_form
      end
  end
end
