# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor listing application forms", type: :system do
  before do
    given_there_are_application_forms
    given_i_am_authorized_as_an_assessor_user
  end

  it "displays a list of applications" do
    when_i_visit_the(:assessor_applications_page)
    then_i_see_a_list_of_applications
  end

  it "paginates the results" do
    when_i_visit_the(:assessor_applications_page)
    then_i_see_the_pagination_controls

    when_i_click_on_next
    then_i_see_the_next_page_of_applications
  end

  it "shows all four sort options with 'Created newest to oldest' selected" do
    when_i_visit_the(:assessor_applications_page)

    expect(assessor_applications_page.sort_options.map(&:text)).to eq(
      [
        "Created newest to oldest",
        "Created oldest to newest",
        "Last updated newest to oldest",
        "Last updated oldest to newest",
      ],
    )
    expect(assessor_applications_page.sort_by.value).to eq("submitted_at_desc")
    then_i_see_a_list_of_applications
  end

  describe "clicking 'Apply sort'" do
    let(:applications_updated_newest_first) { application_forms.reverse }

    before do
      application_forms.each_with_index do |application_form, index|
        application_form.update!(updated_at: 30.days.ago + index.days)
      end
      when_i_visit_the(:assessor_applications_page)
    end

    it "shows applications in 'Created newest to oldest' order" do
      when_i_apply_sort("Created newest to oldest")
      then_i_see_applications_in_this_order(application_forms.first(20))
    end

    it "shows applications in 'Created oldest to newest' order" do
      when_i_apply_sort("Created oldest to newest")
      then_i_see_applications_in_this_order(application_forms.reverse.first(20))
    end

    it "shows applications in 'Last updated newest to oldest' order" do
      when_i_apply_sort("Last updated newest to oldest")
      then_i_see_applications_in_this_order(
        applications_updated_newest_first.first(20),
      )
    end

    it "shows applications in 'Last updated oldest to newest' order" do
      when_i_apply_sort("Last updated oldest to newest")
      then_i_see_applications_in_this_order(
        applications_updated_newest_first.reverse.first(20),
      )
    end

    context "with 'Last updated newest to oldest' selected" do
      before { when_i_apply_sort("Last updated newest to oldest") }

      it "keeps the selected sort and application order on the next page" do
        when_i_click_on_next

        then_i_see_the_selected_sort("Last updated newest to oldest")
        then_i_see_applications_in_this_order(
          applications_updated_newest_first.last(5),
        )
      end

      it "keeps the selected sort and application order after viewing an application" do
        when_i_visit_the(
          :assessor_application_page,
          reference: application_forms.first.reference,
        )
        when_i_visit_the(:assessor_applications_page)

        then_i_see_the_selected_sort("Last updated newest to oldest")
        then_i_see_applications_in_this_order(
          applications_updated_newest_first.first(20),
        )
      end

      it "keeps the selected sort and application order after clearing filters" do
        assessor_applications_page.clear_filters.click

        then_i_see_the_selected_sort("Last updated newest to oldest")
        then_i_see_applications_in_this_order(
          applications_updated_newest_first.first(20),
        )
      end

      it "changes the selected sort and application order to 'Created newest to oldest'" do
        when_i_apply_sort("Created newest to oldest")

        then_i_see_the_selected_sort("Created newest to oldest")
        then_i_see_applications_in_this_order(application_forms.first(20))
      end
    end
  end

  private

  def given_there_are_application_forms
    application_forms
  end

  def when_i_click_on_next
    assessor_applications_page.pagination.next.click
  end

  def when_i_apply_sort(label)
    assessor_applications_page.sort_by.select(label)
    assessor_applications_page.apply_sort.click
  end

  def then_i_see_the_selected_sort(label)
    expect(
      assessor_applications_page.sort_options.select(&:selected?).map(&:text),
    ).to eq([label])
  end

  def then_i_see_applications_in_this_order(applications)
    expected_names =
      applications.map do |application_form|
        "#{application_form.given_names} #{application_form.family_name}"
      end

    expect(visible_names).to eq(expected_names)
  end

  def then_i_see_a_list_of_applications
    page_one_names =
      application_forms[0..19].map do |application_form|
        "#{application_form.given_names} #{application_form.family_name}"
      end

    expect(page_one_names).to eq(visible_names)
  end

  def then_i_see_the_pagination_controls
    expect(assessor_applications_page.pagination).to be_visible
  end

  def then_i_see_the_next_page_of_applications
    page_two_names =
      application_forms[20..24].map do |application_form|
        "#{application_form.given_names} #{application_form.family_name}"
      end

    expect(page_two_names).to eq(visible_names)
  end

  def visible_names
    assessor_applications_page.search_results.map { |result| result.name.text }
  end

  def application_forms
    @application_forms ||=
      create_list(
        :application_form,
        25,
        :with_personal_information,
        :with_assessment,
        :submitted,
        region: create(:region, :in_country, country_code: "FR"),
      ).sort_by(&:submitted_at).reverse
  end
end
