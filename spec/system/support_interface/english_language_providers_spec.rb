# frozen_string_literal: true

require "rails_helper"

RSpec.describe "English language providers support", type: :system do
  before { given_there_are_english_language_providers }

  it "requires permission" do
    given_i_am_authorized_as_an_assessor_user
    when_i_visit_the(:support_english_language_providers_index_page)
    then_i_see_the_forbidden_page
  end

  it "editing english language providers" do
    given_i_am_authorized_as_a_support_user
    when_i_visit_the(:support_english_language_providers_index_page)
    then_i_see_the(:support_english_language_providers_index_page)
    and_i_see_the_english_language_providers

    when_i_click_on_first_english_language_provider
    then_i_see_the(:support_edit_english_language_provider_page)
    and_i_edit_the_english_language_provider
    then_i_see_the(:support_english_language_providers_index_page)
    and_i_see_the_changed_english_language_provider
  end

  def given_there_are_english_language_providers
    create_list(:english_language_provider, 2)
  end

  def and_i_see_the_english_language_providers
    expect(
      support_english_language_providers_index_page.english_language_providers.count,
    ).to eq(2)
  end

  def when_i_click_on_first_english_language_provider
    support_english_language_providers_index_page
      .english_language_providers
      .first
      .name_link
      .click
  end

  def and_i_edit_the_english_language_provider
    support_edit_english_language_provider_page.form.name_field.fill_in with:
      "New name"
    support_edit_english_language_provider_page.form.submit_button.click
  end

  def and_i_see_the_changed_english_language_provider
    expect(
      support_english_language_providers_index_page
        .english_language_providers
        .first
        .name_heading
        .text,
    ).to eq("New name")
  end
end
