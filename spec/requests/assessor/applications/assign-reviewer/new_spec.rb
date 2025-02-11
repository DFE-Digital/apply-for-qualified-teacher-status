# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /assessor/applications/:reference/assign-reviewer",
               type: :request do
  subject(:assign_assessor) do
    get "/assessor/applications/#{application_form.reference}/assign-reviewer"
  end

  let(:application_form) { create :application_form, :submitted }

  before do
    create(:staff, :with_assess_permission, name: "Active Assessor")
    create(
      :staff,
      :with_assess_permission,
      :archived,
      name: "Archived Assessor",
    )
    sign_in(create(:staff, :with_assess_permission))
    assign_assessor
  end

  it "displays the page with the 'Select an reviewer' title" do
    expect(response.body).to include("Select a reviewer")
  end

  it "displays the active assessor as an option" do
    expect(response.body).to include("Active Assessor")
  end

  it "does not display the archived assessor as an option" do
    expect(response.body).not_to include("Archived Assessor")
  end
end
