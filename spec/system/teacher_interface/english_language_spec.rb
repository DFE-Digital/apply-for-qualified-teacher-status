# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher English language", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_a_user(teacher)
    given_an_application_form_exists
    given_malware_scanning_is_enabled
  end

  it "citizenship exempt" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_english_language_task

    when_i_click_the_english_language_task
    then_i_see_the(
      :teacher_english_language_exemption_page,
      exemption_field: "citizenship",
    )

    when_i_am_exempt
    then_i_see_the(:teacher_check_english_language_page)
    and_i_see_that_i_am_exempt_by_citizenship
  end

  it "qualification exempt" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_english_language_task

    when_i_click_the_english_language_task
    then_i_see_the(
      :teacher_english_language_exemption_page,
      exemption_field: "citizenship",
    )

    when_i_am_not_exempt
    then_i_see_the(
      :teacher_english_language_exemption_page,
      exemption_field: "qualification",
    )

    when_i_am_exempt
    then_i_see_the(:teacher_check_english_language_page)
    and_i_see_that_i_am_exempt_by_qualification
  end

  it "medium of instruction" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_english_language_task

    when_i_click_the_english_language_task
    then_i_see_the(
      :teacher_english_language_exemption_page,
      exemption_field: "citizenship",
    )

    when_i_am_not_exempt
    then_i_see_the(
      :teacher_english_language_exemption_page,
      exemption_field: "qualification",
    )

    when_i_am_not_exempt
    then_i_see_the(:teacher_english_language_proof_method_page)

    when_i_use_a_medium_of_instruction
    then_i_see_the(:teacher_upload_document_page)

    when_i_upload_a_medium_of_instruction
    then_i_see_the(:teacher_check_document_page)
    and_i_dont_upload_another_page
    then_i_see_the(:teacher_check_english_language_page)
    and_i_see_the_my_medium_of_instruction
  end

  it "provider reference" do
    given_there_are_english_language_providers

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_english_language_task

    when_i_click_the_english_language_task
    then_i_see_the(
      :teacher_english_language_exemption_page,
      exemption_field: "citizenship",
    )

    when_i_am_not_exempt
    then_i_see_the(
      :teacher_english_language_exemption_page,
      exemption_field: "qualification",
    )

    when_i_am_not_exempt
    then_i_see_the(:teacher_english_language_proof_method_page)

    when_i_use_a_provider_reference
    then_i_see_the(:teacher_english_language_provider_page)
    and_i_see_the_providers

    when_i_select_the_first_provider
    then_i_see_the(:teacher_english_language_provider_reference_page)
    and_i_see_the_provider_information

    when_i_fill_in_a_reference
    then_i_see_the(:teacher_check_english_language_page)
    and_i_see_the_my_provider_reference
  end

  it "other provider" do
    given_there_are_english_language_providers
    given_the_application_form_accepts_reduced_evidence

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_the_english_language_task

    when_i_click_the_english_language_task
    then_i_see_the(
      :teacher_english_language_exemption_page,
      exemption_field: "citizenship",
    )

    when_i_am_not_exempt
    then_i_see_the(
      :teacher_english_language_exemption_page,
      exemption_field: "qualification",
    )

    when_i_am_not_exempt
    then_i_see_the(:teacher_english_language_proof_method_page)

    when_i_use_a_provider_reference
    then_i_see_the(:teacher_english_language_provider_page)
    and_i_see_the_providers_with_an_other

    when_i_select_the_other_provider
    then_i_see_the(:teacher_upload_document_page)

    when_i_upload_a_file
    then_i_see_the(:teacher_check_document_page)

    when_i_dont_need_to_upload_another_file
    then_i_see_the(:teacher_check_english_language_page)
    and_i_see_the_my_other_provider
  end

  private

  def given_an_application_form_exists
    application_form
  end

  def given_there_are_english_language_providers
    english_language_providers
  end

  def given_the_application_form_accepts_reduced_evidence
    application_form.update!(reduced_evidence_accepted: true)
  end

  def and_i_see_the_english_language_task
    expect(teacher_application_page.english_language_task_item).to_not be_nil
  end

  def when_i_click_the_english_language_task
    teacher_application_page.english_language_task_item.click
  end

  def when_i_am_exempt
    teacher_english_language_exemption_page.form.true_radio_item.choose
    teacher_english_language_exemption_page.form.continue_button.click
  end

  def and_i_see_that_i_am_exempt_by_citizenship
    expect(teacher_check_english_language_page.summary_list.rows.count).to eq(1)

    summary_list_row =
      teacher_check_english_language_page.summary_list.rows.first
    expect(summary_list_row.key.text).to eq(
      "Were you born in or hold citizenship of any of the countries below?",
    )
    expect(summary_list_row.value.text).to eq("Yes")
  end

  def when_i_am_not_exempt
    teacher_english_language_exemption_page.form.false_radio_item.choose
    teacher_english_language_exemption_page.form.continue_button.click
  end

  def and_i_see_that_i_am_exempt_by_qualification
    expect(teacher_check_english_language_page.summary_list.rows.count).to eq(2)

    summary_list_row =
      teacher_check_english_language_page.summary_list.rows.second
    expect(summary_list_row.key.text).to eq(
      "Was your teaching qualification or university degree taught in any of the following countries?",
    )
    expect(summary_list_row.value.text).to eq("Yes")
  end

  def when_i_use_a_medium_of_instruction
    teacher_english_language_proof_method_page
      .form
      .medium_of_instruction_radio_item
      .choose
    teacher_english_language_proof_method_page.form.continue_button.click
  end

  def when_i_use_a_provider_reference
    teacher_english_language_proof_method_page.form.provider_radio_item.choose
    teacher_english_language_proof_method_page.form.continue_button.click
  end

  def when_i_upload_a_medium_of_instruction
    teacher_upload_document_page.form.original_attachment.attach_file Rails.root.join(
      file_fixture("upload.pdf"),
    )
    teacher_upload_document_page.form.continue_button.click
  end

  def and_i_dont_upload_another_page
    teacher_check_document_page.form.false_radio_item.choose
    teacher_check_document_page.form.continue_button.click
  end

  def and_i_see_the_my_medium_of_instruction
    expect(teacher_check_english_language_page.summary_list.rows.count).to eq(4)

    proof_method_summary_list_row =
      teacher_check_english_language_page.summary_list.rows.third
    expect(proof_method_summary_list_row.key.text).to eq(
      "Chosen verification method",
    )
    expect(proof_method_summary_list_row.value.text).to eq(
      "Medium of instruction",
    )

    document_summary_list_row =
      teacher_check_english_language_page.summary_list.rows.fourth
    expect(document_summary_list_row.key.text).to eq(
      "Medium of instruction document",
    )
    expect(document_summary_list_row.value.text).to eq(
      "upload.pdf (opens in a new tab)",
    )
  end

  def and_i_see_the_providers
    expect(teacher_english_language_provider_page.form.radio_items.count).to eq(
      5,
    )

    5.times do |i|
      expect(
        teacher_english_language_provider_page.form.radio_items[i].text,
      ).to eq(english_language_providers[i].name)
    end
  end

  def when_i_select_the_first_provider
    teacher_english_language_provider_page.form.radio_items.first.choose
    teacher_english_language_provider_page.form.continue_button.click
  end

  def and_i_see_the_provider_information
    english_language_provider = english_language_providers.first
    expect(teacher_english_language_provider_reference_page).to have_content(
      english_language_provider.name,
    )
    expect(teacher_english_language_provider_reference_page).to have_content(
      english_language_provider.b2_level_requirement_prefix,
    )
    expect(teacher_english_language_provider_reference_page).to have_content(
      english_language_provider.b2_level_requirement,
    )
    expect(teacher_english_language_provider_reference_page).to have_content(
      english_language_provider.reference_name,
    )
    expect(teacher_english_language_provider_reference_page).to have_content(
      english_language_provider.reference_hint,
    )
  end

  def when_i_fill_in_a_reference
    teacher_english_language_provider_reference_page.form.reference_input.fill_in with:
      "abc"
    teacher_english_language_provider_reference_page.form.continue_button.click
  end

  def and_i_see_the_my_provider_reference
    expect(teacher_check_english_language_page.summary_list.rows.count).to eq(5)

    proof_method_summary_list_row =
      teacher_check_english_language_page.summary_list.rows.third
    expect(proof_method_summary_list_row.key.text).to eq(
      "Chosen verification method",
    )
    expect(proof_method_summary_list_row.value.text).to eq(
      "Approved test provider",
    )

    provider_summary_list_row =
      teacher_check_english_language_page.summary_list.rows.fourth
    expect(provider_summary_list_row.key.text).to eq("Your approved provider")
    expect(provider_summary_list_row.value.text).to eq(
      english_language_providers.first.name,
    )

    reference_summary_list_row =
      teacher_check_english_language_page.summary_list.rows.fifth
    expect(reference_summary_list_row.key.text).to eq("Your reference number")
    expect(reference_summary_list_row.value.text).to eq("abc")
  end

  def and_i_see_the_providers_with_an_other
    expect(teacher_english_language_provider_page.form.radio_items.count).to eq(
      6,
    )

    5.times do |i|
      expect(
        teacher_english_language_provider_page.form.radio_items[i].text,
      ).to eq(english_language_providers[i].name)
    end

    expect(
      teacher_english_language_provider_page.form.radio_items[5].text,
    ).to eq("Other approved provider")
  end

  def when_i_select_the_other_provider
    teacher_english_language_provider_page.form.radio_items.last.choose
    teacher_english_language_provider_page.form.continue_button.click
  end

  def when_i_upload_a_file
    teacher_upload_document_page.form.original_attachment.attach_file Rails.root.join(
      file_fixture("upload.pdf"),
    )
    teacher_upload_document_page.form.continue_button.click
  end

  def when_i_dont_need_to_upload_another_file
    teacher_check_document_page.form.false_radio_item.input.click
    teacher_check_document_page.form.continue_button.click
  end

  def and_i_see_the_my_other_provider
    expect(teacher_check_english_language_page.summary_list.rows.count).to eq(5)

    proof_method_summary_list_row =
      teacher_check_english_language_page.summary_list.rows.third
    expect(proof_method_summary_list_row.key.text).to eq(
      "Chosen verification method",
    )
    expect(proof_method_summary_list_row.value.text).to eq(
      "Approved test provider",
    )

    provider_summary_list_row =
      teacher_check_english_language_page.summary_list.rows.fourth
    expect(provider_summary_list_row.key.text).to eq("Your approved provider")
    expect(provider_summary_list_row.value.text).to eq("Other")

    reference_summary_list_row =
      teacher_check_english_language_page.summary_list.rows.fifth
    expect(reference_summary_list_row.key.text).to eq(
      "English language proficiency test document",
    )
    expect(reference_summary_list_row.value.text).to eq(
      "upload.pdf (opens in a new tab)",
    )
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def application_form
    @application_form ||= create(:application_form, teacher:)
  end

  def english_language_providers
    @english_language_providers ||= create_list(:english_language_provider, 5)
  end
end
