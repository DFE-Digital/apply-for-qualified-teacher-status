# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /assessor/applications/:reference/assign-assessor",
               type: :request do
  subject(:assign_assessor) do
    get "/assessor/applications/#{application_form.reference}/assign-assessor"
  end

  let(:application_form) { create :application_form, :submitted }
  let(:signed_in_staff) { create(:staff, :with_assess_permission) }

  before do
    create(:staff, :with_assess_permission, name: "Zachary Assessor")
    create(:staff, :with_assess_permission, name: "Aaron Assessor")
    create(:staff, :with_assess_permission, name: "Bernard Assessor")
    create(
      :staff,
      :with_assess_permission,
      :archived,
      name: "Archived Assessor",
    )
    sign_in(signed_in_staff)
    assign_assessor
  end

  it "displays the page with the 'Select an assessor' title" do
    expect(response.body).to include("Select an assessor")
  end

  it "displays the active assessors as options" do
    expect(response.body).to include("Aaron Assessor")
    expect(response.body).to include("Bernard Assessor")
    expect(response.body).to include("Zachary Assessor")
  end

  it "does not display the archived assessor as an option" do
    expect(response.body).not_to include("Archived Assessor")
  end

  it "displays the assessors in alphabetical order" do
    assessor_names =
      Nokogiri
        .HTML(response.body)
        .css(".govuk-radios__label")
        .map(&:text)
        .map(&:strip)
        .reject { |name| name == "Not assigned" }

    expected_names = [
      "Aaron Assessor",
      "Bernard Assessor",
      "Zachary Assessor",
      signed_in_staff.name,
    ].sort

    expect(assessor_names).to eq(expected_names)
  end
end
