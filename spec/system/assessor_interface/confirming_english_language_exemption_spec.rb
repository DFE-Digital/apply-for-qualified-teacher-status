require "rails_helper"

RSpec.describe "Assessor confirms English language section", type: :system do
  it "exemption via citizenship in the Personal Information section" do
    given_the_service_is_open
    given_there_is_an_application_form
    and_the_application_states_english_language_exemption_by_citizenship
    given_i_am_authorized_as_an_assessor_user

    when_i_visit_the(:assessor_application_page, application_id:)
    then_i_see_the_application

    when_i_visit_the(
      :assessor_check_english_language_proficiency_page,
      application_id:,
      assessment_id:,
      section_id: section_id("english_language_proficiency"),
    )
    then_i_am_asked_to_confirm_english_language_proficiency_in_the_personal_information_section

    when_i_visit_the(
      :assessor_check_personal_information_page,
      application_id:,
      assessment_id:,
      section_id: section_id("personal_information"),
    )
    then_i_can_see_failure_reasons_if_i_do_not_wish_to_confirm(
      assessor_check_personal_information_page,
      "english_language_exemption_by_citizenship_not_confirmed",
    )
    and_i_confirm_english_language_exemption(
      assessor_check_personal_information_page,
    )
    and_i_confirm_the_section_as_complete(
      assessor_check_personal_information_page,
    )
    then_i_see_the_personal_information_section_is_complete
    and_the_english_language_section_is_complete
  end

  it "exemption via qualification in the Qualifications section" do
    given_the_service_is_open
    given_there_is_an_application_form
    and_the_application_states_english_language_exemption_by_qualification
    given_i_am_authorized_as_an_assessor_user

    when_i_visit_the(:assessor_application_page, application_id:)
    then_i_see_the_application

    when_i_visit_the(
      :assessor_check_english_language_proficiency_page,
      application_id:,
      assessment_id:,
      section_id: section_id("english_language_proficiency"),
    )
    then_i_am_asked_to_confirm_english_language_proficiency_in_the_qualifications_section

    when_i_visit_the(
      :assessor_check_qualifications_page,
      application_id:,
      assessment_id:,
      section_id: section_id("qualifications"),
    )
    then_i_can_see_failure_reasons_if_i_do_not_wish_to_confirm(
      assessor_check_qualifications_page,
      "english_language_exemption_by_qualification_not_confirmed",
    )
    and_i_confirm_english_language_exemption(assessor_check_qualifications_page)
    and_i_confirm_the_section_as_complete(assessor_check_qualifications_page)
    then_i_see_the_qualifications_section_is_complete
    and_the_english_language_section_is_complete
  end

  it "confirmation of proficiency by SELT from approved provider" do
    given_the_service_is_open
    given_there_is_an_application_form
    and_the_application_english_language_proof_method_is_provider
    given_i_am_authorized_as_an_assessor_user
    when_i_visit_the(
      :assessor_check_english_language_proficiency_page,
      application_id:,
      assessment_id:,
      section_id: section_id("english_language_proficiency"),
    )
    then_i_am_asked_to_confirm_english_language_proficiency_by_provider
    and_i_can_see_provider_failure_reasons_if_i_do_not_wish_to_confirm
    and_i_confirm_the_section_as_complete(
      assessor_check_english_language_proficiency_page,
    )
    then_the_english_language_section_is_complete
  end

  it "confirmation of proficiency by medium of instruction document" do
    given_the_service_is_open
    given_there_is_an_application_form
    and_the_application_english_language_proof_method_is_moi
    given_i_am_authorized_as_an_assessor_user
    when_i_visit_the(
      :assessor_check_english_language_proficiency_page,
      application_id:,
      assessment_id:,
      section_id: section_id("english_language_proficiency"),
    )
    then_i_am_asked_to_confirm_english_language_proficiency_by_moi
    and_i_can_see_moi_failure_reasons_if_i_do_not_wish_to_confirm
    and_i_confirm_the_section_as_complete(
      assessor_check_english_language_proficiency_page,
    )
    then_the_english_language_section_is_complete
  end

  private

  def given_there_is_an_application_form
    application_form
  end

  def and_the_application_states_english_language_exemption_by_citizenship
    application_form.update!(english_language_citizenship_exempt: true)
    application_form
      .assessment
      .sections
      .find_by(key: :personal_information)
      .update!(
        failure_reasons: [
          "english_language_exemption_by_citizenship_not_confirmed",
        ],
      )
  end

  def and_the_application_states_english_language_exemption_by_qualification
    application_form.update!(english_language_qualification_exempt: true)
    application_form
      .assessment
      .sections
      .find_by(key: :qualifications)
      .update!(
        failure_reasons: [
          "english_language_exemption_by_qualification_not_confirmed",
        ],
      )
  end

  def and_the_application_english_language_proof_method_is_provider
    application_form.update!(
      english_language_proof_method: "provider",
      english_language_provider: create(:english_language_provider),
    )
    application_form
      .assessment
      .sections
      .find_by(key: :english_language_proficiency)
      .update!(
        checks: ["english_language_valid_provider"],
        failure_reasons: ["english_language_qualification_invalid"],
      )
  end

  def and_the_application_english_language_proof_method_is_moi
    application_form.update!(
      english_language_proof_method: "medium_of_instruction",
    )
    application_form
      .assessment
      .sections
      .find_by(key: :english_language_proficiency)
      .update!(
        checks: ["english_language_valid_moi"],
        failure_reasons: ["english_language_moi_invalid_format"],
      )
  end

  def then_i_see_the_application
    expect(assessor_application_page.name_summary.value).to have_text(
      "#{application_form.given_names} #{application_form.family_name}",
    )
  end

  def then_i_am_asked_to_confirm_english_language_proficiency_in_the_personal_information_section
    expect(assessor_check_english_language_proficiency_page.heading.text).to eq(
      "Check English language proficiency",
    )
    expect(
      assessor_check_english_language_proficiency_page.h2s.last.text,
    ).to eq("English language exemption by birth/citizenship")
    assessor_check_english_language_proficiency_page.return_button.click
  end

  def then_i_am_asked_to_confirm_english_language_proficiency_in_the_qualifications_section
    expect(assessor_check_english_language_proficiency_page.heading.text).to eq(
      "Check English language proficiency",
    )
    expect(
      assessor_check_english_language_proficiency_page.h2s.last.text,
    ).to eq("English language exemption by country of study")
    assessor_check_english_language_proficiency_page.return_button.click
  end

  def then_i_am_asked_to_confirm_english_language_proficiency_by_provider
    expect(assessor_check_english_language_proficiency_page.heading.text).to eq(
      "Check English language proficiency",
    )
    expect(
      assessor_check_english_language_proficiency_page.cards.first.heading.text,
    ).to eq("Verify your English language proficiency")
    expect(
      assessor_check_english_language_proficiency_page.lists.last.text,
    ).to eq(
      I18n.t(
        "assessor_interface.assessment_sections.checks.english_language_valid_provider",
      ),
    )
  end

  def then_i_am_asked_to_confirm_english_language_proficiency_by_moi
    expect(assessor_check_english_language_proficiency_page.heading.text).to eq(
      "Check English language proficiency",
    )
    expect(
      assessor_check_english_language_proficiency_page.cards.first.heading.text,
    ).to eq("Verify your English language proficiency")

    expect(
      assessor_check_english_language_proficiency_page.lists.last.text,
    ).to eq(
      I18n.t(
        "assessor_interface.assessment_sections.checks.english_language_valid_moi",
      ),
    )
  end

  def and_i_can_see_provider_failure_reasons_if_i_do_not_wish_to_confirm
    then_i_can_see_failure_reasons_if_i_do_not_wish_to_confirm(
      assessor_check_english_language_proficiency_page,
      "english_language_qualification_invalid",
    )
  end

  def and_i_can_see_moi_failure_reasons_if_i_do_not_wish_to_confirm
    then_i_can_see_failure_reasons_if_i_do_not_wish_to_confirm(
      assessor_check_english_language_proficiency_page,
      "english_language_moi_invalid_format",
    )
  end

  def then_i_can_see_failure_reasons_if_i_do_not_wish_to_confirm(page, key)
    page.form.no_radio_item.choose

    expect(page.form.failure_reason_checkbox_items.last.text).to eq(
      I18n.t(
        key,
        scope: %i[
          assessor_interface
          assessment_sections
          failure_reasons
          as_statement
        ],
      ),
    )
  end

  def and_i_confirm_english_language_exemption(page)
    page.exemption_form.english_language_exempt.check
  end

  def and_i_confirm_the_section_as_complete(page)
    page.form.yes_radio_item.choose
    page.form.continue_button.click
  end

  def then_i_see_the_personal_information_section_is_complete
    assert_section_is_complete(:personal_information)
  end

  def then_i_see_the_qualifications_section_is_complete
    assert_section_is_complete(:qualifications)
  end

  def and_the_english_language_section_is_complete
    assert_section_is_complete(:english_language_proficiency)
  end
  alias_method :then_the_english_language_section_is_complete,
               :and_the_english_language_section_is_complete

  def assert_section_is_complete(section)
    expect(
      assessor_application_page.send("#{section}_task").status_tag.text,
    ).to eq("COMPLETED")
  end

  def application_form
    @application_form ||=
      begin
        application_form =
          create(
            :application_form,
            :with_work_history,
            :with_personal_information,
            :submitted,
            :with_assessment,
          )

        create(
          :assessment_section,
          :personal_information,
          assessment: application_form.assessment,
        )
        create(
          :assessment_section,
          :qualifications,
          assessment: application_form.assessment,
        )
        create(
          :assessment_section,
          :english_language_proficiency,
          assessment: application_form.assessment,
        )

        application_form
      end
  end

  def application_id
    application_form.id
  end

  def assessment_id
    application_form.assessment.id
  end

  def section_id(key)
    application_form.assessment.sections.find_by(key:).id
  end
end
