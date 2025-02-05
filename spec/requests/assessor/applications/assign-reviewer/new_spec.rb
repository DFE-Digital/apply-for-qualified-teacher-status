# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /assessor/applications/:reference/assign-reviewer", type: :request do
  subject(:assign_assessor) { get "/assessor/applications/#{application_form.reference}/assign-reviewer" }

  let(:application_form) { create :application_form, :submitted }

  before do
    sign_in(create(:staff, :with_assess_permission))
    assign_assessor
  end

  it "gets page" do
    expect(response.body).to include("Select")
  end
end
