# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::DraftApplicationFormViewObject do
  subject(:view_object) { described_class.new(application_form:) }

  let(:application_form) do
    build(
      :application_form,
      reference: "0000123",
      given_names: "",
      family_name: "",
      region: build(:region, country: build(:country, code: "FR")),
      teacher: build(:teacher, email: "example-draft@example.com"),
      created_at: Time.zone.local(2026, 5, 31, 12),
    )
  end

  around do |example|
    travel_to(Time.zone.local(2026, 11, 24, 12)) { example.run }
  end

  describe "#summary_rows" do
    it "presents draft details without editing actions" do
      expect(view_object.summary_rows).to eq(
        [
          { key: { text: "Name" }, value: { text: "Not provided" } },
          { key: { text: "Country trained in" }, value: { text: "France" } },
          {
            key: {
              text: "Email",
            },
            value: {
              text: "example-draft@example.com",
            },
          },
          { key: { text: "GOV.UK One Login" }, value: { text: "Unlinked" } },
          { key: { text: "Draft created" }, value: { text: "31 May 2026" } },
          { key: { text: "Days until deletion" }, value: { text: "6 days" } },
          { key: { text: "Reference" }, value: { text: "0000123" } },
        ],
      )
    end

    it "shows the applicant's name when provided" do
      application_form.assign_attributes(
        given_names: "Example",
        family_name: "Applicant",
      )

      expect(view_object.summary_rows.first).to eq(
        key: {
          text: "Name",
        },
        value: {
          text: "Example Applicant",
        },
      )
    end

    it "shows a linked account without displaying the One Login identifier" do
      application_form.teacher.gov_one_id = "example-one-login-subject"

      expect(view_object.summary_rows[3]).to eq(
        key: {
          text: "GOV.UK One Login",
        },
        value: {
          text: "Linked",
        },
      )
    end
  end
end
