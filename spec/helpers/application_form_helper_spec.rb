# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationFormHelper do
  let(:region) do
    create(:region, name: "Region", country: create(:country, code: "US"))
  end

  let(:application_form) do
    create(
      :application_form,
      region:,
      reference: "0000001",
      created_at: Date.new(2020, 1, 1),
      given_names: "Given",
      family_name: "Family"
    )
  end

  describe "#application_form_full_name" do
    subject(:full_name) { application_form_full_name(application_form) }

    it { is_expected.to eq("Given Family") }
  end

  describe "#application_form_summary_rows" do
    subject(:summary_rows) do
      application_form_summary_rows(
        application_form,
        include_name: true,
        include_reference: true,
        include_notes: true
      )
    end

    it do
      is_expected.to eq(
        [
          {
            key: {
              text: "Name"
            },
            value: {
              text: "Given Family"
            },
            actions: []
          },
          {
            key: {
              text: "Country trained in"
            },
            value: {
              text: "United States"
            },
            actions: []
          },
          {
            key: {
              text: "State/territory trained in"
            },
            value: {
              text: "Region"
            },
            actions: []
          },
          {
            key: {
              text: "Created on"
            },
            value: {
              text: " 1 January 2020"
            },
            actions: []
          },
          {
            key: {
              text: "Days remaining in SLA"
            },
            value: {
              text: "Not implemented"
            },
            actions: []
          },
          {
            key: {
              text: "Assigned to"
            },
            value: {
              text: "Not implemented"
            },
            actions: [{ href: "#" }]
          },
          {
            key: {
              text: "Reviewer"
            },
            value: {
              text: "Not implemented"
            },
            actions: [{ href: "#" }]
          },
          {
            key: {
              text: "Reference"
            },
            value: {
              text: "0000001"
            },
            actions: []
          },
          {
            key: {
              text: "Status"
            },
            value: {
              text:
                "<strong class=\"govuk-tag govuk-tag--blue\">Not implemented</strong>"
            },
            actions: []
          },
          {
            key: {
              text: "Notes"
            },
            value: {
              text: "Not implemented"
            },
            actions: []
          }
        ]
      )
    end
  end
end
