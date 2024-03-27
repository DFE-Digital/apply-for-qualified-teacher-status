require "rails_helper"

RSpec.describe "Assessor view application form", type: :system do
  it "displays the application overview" do
    given_there_is_an_application_form
    given_i_am_authorized_as_an_assessor_user

    when_i_visit_the(:assessor_application_page, reference:)
    then_i_see_the_application
    and_i_see_the_assessment_tasks

    when_i_click_back_link
    then_i_see_the(:assessor_applications_page)
  end

  private

  def given_there_is_an_application_form
    application_form
  end

  def when_i_click_back_link
    assessor_application_page.back_link.click
  end

  def then_i_see_the_application
    expect(assessor_application_page.name_summary.value).to have_text(
      "#{application_form.given_names} #{application_form.family_name}",
    )
  end

  def and_i_see_the_assessment_tasks
    expect(assessor_application_page.task_list.sections.count).to eq(1)

    section_links =
      assessor_application_page.task_list.sections.first.items.map do |item|
        item.name.text
      end

    expect(section_links).to eq(
      [
        "Check personal information",
        "Check qualifications",
        "Initial assessment recommendation",
      ],
    )
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

        application_form
      end
  end

  delegate :reference, to: :application_form
end
