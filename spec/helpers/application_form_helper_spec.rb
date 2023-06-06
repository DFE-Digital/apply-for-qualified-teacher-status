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
        include_name: true,
        include_reference: true,
      )
    end

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
            actions: [],
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
          {
            key: {
              text: "State/territory trained in",
            },
            value: {
              text: "Region",
            },
            actions: [],
          },
          {
            key: {
              text: "Created on",
            },
            value: {
              text: " 1 January 2020",
            },
            actions: [],
          },
          {
            key: {
              text: "Working days since submission",
            },
            value: {
              text: "0 days",
            },
            actions: [],
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
                href:
                  assessor_interface_application_form_assign_assessor_path(
                    application_form,
                  ),
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
                href:
                  assessor_interface_application_form_assign_reviewer_path(
                    application_form,
                  ),
              },
            ],
          },
          {
            key: {
              text: "Reference",
            },
            value: {
              text: "0000001",
            },
            actions: [],
          },
          {
            key: {
              text: "Status",
            },
            value: {
              text:
                "<strong class=\"govuk-tag govuk-tag--grey app-search-result__item__tag\" id=\"application-form-#{application_form.id}-status\">Not started</strong>\n",
            },
            actions: [],
          },
        ],
      )
    end

    context "include_reviewer false" do
      subject(:summary_rows_without_reviewer) do
        application_form_summary_rows(
          application_form,
          include_name: true,
          include_reference: true,
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

  describe "#application_form_display_work_history_before_teaching_qualification_banner?" do
    subject do
      application_form_display_work_history_before_teaching_qualification_banner?(
        application_form,
      )
    end

    context "when both dates are present and work history date is earlier" do
      before do
        create(
          :qualification,
          application_form:,
          certificate_date: Date.new(2023, 1, 1),
        )
        application_form.work_histories.create!(
          start_date: Date.new(2022, 1, 1),
        )
      end

      it "returns true" do
        expect(subject).to be true
      end
    end

    context "when both dates are present and work history date is later" do
      before do
        create(
          :qualification,
          application_form:,
          certificate_date: Date.new(2022, 1, 1),
        )
        application_form.work_histories.create!(
          start_date: Date.new(2023, 1, 1),
        )
      end

      it "returns false" do
        expect(subject).to be false
      end
    end

    context "when either date is missing" do
      before do
        create(:qualification, application_form:, certificate_date: nil)
        application_form.work_histories.destroy_all
      end

      it "returns false" do
        expect(subject).to be false
      end
    end
  end
end
