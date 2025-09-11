# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /assessor/applications/:reference/assign-reviewer",
               type: :request do
  subject(:assign_reviewer) do
    get "/assessor/applications/#{application_form.reference}/assign-reviewer"
  end

  let(:application_form) { create :application_form, :submitted }
  let(:signed_in_staff) { create(:staff, :with_assess_permission) }

  before do
    create(:staff, :with_assess_permission, name: "Zachary Reviewer")
    create(:staff, :with_assess_permission, name: "Aaron Reviewer")
    create(:staff, :with_assess_permission, name: "Bernard Reviewer")
    create(
      :staff,
      :with_assess_permission,
      :archived,
      name: "Archived Reviewer",
    )
    sign_in(signed_in_staff)
    assign_reviewer
  end

  it "displays the page with the 'Select a reviewer' title" do
    expect(response.body).to include("Select a reviewer")
  end

  it "displays the active reviewers as options" do
    expect(response.body).to include("Aaron Reviewer")
    expect(response.body).to include("Bernard Reviewer")
    expect(response.body).to include("Zachary Reviewer")
  end

  it "does not display the archived reviewer as an option" do
    expect(response.body).not_to include("Archived Reviewer")
  end

  it "displays the reviewers in alphabetical order" do
    reviewer_names =
      Nokogiri
        .HTML(response.body)
        .css(".govuk-radios__label")
        .map(&:text)
        .map(&:strip)
        .reject { |name| name == "Not assigned" }

    expected_names = [
      "Aaron Reviewer",
      "Bernard Reviewer",
      "Zachary Reviewer",
      signed_in_staff.name,
    ].sort

    expect(reviewer_names).to eq(expected_names)
  end
end
