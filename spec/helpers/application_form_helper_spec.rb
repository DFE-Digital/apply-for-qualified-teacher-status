# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationFormHelper do
  let(:region) do
    create(:region, name: "Region", country: create(:country, code: "US"))
  end

  let(:application_form) do
    create(
      :application_form,
      :submitted,
      region:,
      reference: "0000001",
      submitted_at: Date.new(2020, 1, 1),
      given_names: "Given",
      family_name: "Family",
    )
  end

  describe "#application_form_full_name" do
    subject(:full_name) { application_form_full_name(application_form) }

    it { is_expected.to eq("Given Family") }

    context "without names" do
      before { application_form.update!(given_names: "", family_name: "") }

      it { is_expected.to eq("applicant") }
    end
  end

  describe "#application_form_summary_rows" do
    subject(:summary_rows) do
      application_form_summary_rows(
        application_form,
        current_staff:,
        include_name: true,
      )
    end

    let(:current_staff) { create(:staff) }

    it do
      is_expected.to eq(
        [
          {
            key: {
              text: "Name",
            },
            value: {
              text: "Given Family",
            },
            actions: [],
          },
          {
            key: {
              text: "Country trained in",
            },
            value: {
              text: "United States",
            },
          },
          {
            key: {
              text: "State/territory trained in",
            },
            value: {
              text: "Region",
            },
          },
          {
            key: {
              text: "Email",
            },
            value: {
              text: application_form.teacher.email,
            },
            actions: [],
          },
          { key: { text: "Created on" }, value: { text: " 1 January 2020" } },
          {
            key: {
              text: "Working days since submission",
            },
            value: {
              text: "0 days",
            },
          },
          {
            key: {
              text: "Assigned to",
            },
            value: {
              text: "Not assigned",
            },
            actions: [
              {
                visually_hidden_text: "Assigned to",
                href: [:assessor_interface, application_form, :assign_assessor],
              },
            ],
          },
          {
            key: {
              text: "Reviewer",
            },
            value: {
              text: "Not assigned",
            },
            actions: [
              {
                visually_hidden_text: "Reviewer",
                href: [:assessor_interface, application_form, :assign_reviewer],
              },
            ],
          },
          { key: { text: "Reference" }, value: { text: "0000001" } },
          {
            key: {
              text: "Status",
            },
            value: {
              text:
                "<strong class=\"govuk-tag govuk-tag--grey\">Assessment not started</strong>\n",
            },
          },
        ],
      )
    end

    context "user has change email permission" do
      let(:current_staff) { create(:staff, :with_change_email_permission) }

      it "has an action to change the name" do
        email_row = summary_rows.find { |row| row[:key][:text] == "Email" }

        expect(email_row).to eq(
          {
            key: {
              text: "Email",
            },
            value: {
              text: application_form.teacher.email,
            },
            actions: [
              {
                visually_hidden_text: "Email",
                href: [:email, :assessor_interface, application_form],
              },
            ],
          },
        )
      end
    end

    context "user has change name permission" do
      let(:current_staff) { create(:staff, :with_change_name_permission) }

      it "has an action to change the name" do
        name_row = summary_rows.find { |row| row[:key][:text] == "Name" }

        expect(name_row).to eq(
          {
            key: {
              text: "Name",
            },
            value: {
              text: "Given Family",
            },
            actions: [
              {
                visually_hidden_text: "Name",
                href: [:name, :assessor_interface, application_form],
              },
            ],
          },
        )
      end
    end

    context "include_reviewer false" do
      subject(:summary_rows_without_reviewer) do
        application_form_summary_rows(
          application_form,
          current_staff:,
          include_name: true,
          include_reviewer: false,
        )
      end

      it "does not return the reviewer element" do
        expect(
          summary_rows_without_reviewer.find do |row|
            row[:key][:text] == "Reviewer"
          end,
        ).to be_nil
      end
    end

    context "region has an empty name" do
      before { application_form.region.update(name: "") }

      it "does not return the region element" do
        expect(
          summary_rows.find do |row|
            row[:key][:text] == "State/territory trained in"
          end,
        ).to be_nil
      end
    end
  end
end
