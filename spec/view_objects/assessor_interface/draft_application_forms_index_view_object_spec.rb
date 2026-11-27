# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::DraftApplicationFormsIndexViewObject do
  subject(:view_object) { described_class.new(params:, session:) }

  let(:params) { {} }
  let(:session) { {} }
  let(:region) { create(:region, :in_country, country_code: "FR") }
  let(:teacher) { create(:teacher, email: "draft-applicant@example.com") }

  around do |example|
    travel_to(Time.zone.local(2026, 11, 24, 12)) { example.run }
  end

  describe "#application_forms_records" do
    let!(:draft) { create(:application_form, region:, teacher:) }

    before { create(:application_form, :submitted, region:, teacher:) }

    it "only includes drafts" do
      expect(view_object.application_forms_records).to contain_exactly(draft)
    end

    it "includes drafts awaiting deletion" do
      draft.update!(created_at: 7.months.ago)

      expect(view_object.application_forms_records).to contain_exactly(draft)
    end

    it "does not use the submitted application's filters" do
      session[:filter_params] = { email: "unmatched@example.com" }

      expect(view_object.application_forms_records).to contain_exactly(draft)
    end

    context "with a draft email filter" do
      let(:session) do
        { draft_filter_params: { "email" => " DRAFT-APPLICANT@EXAMPLE.COM " } }
      end

      before { create(:application_form, region:) }

      it "uses the existing exact, normalized email matching" do
        expect(view_object.application_forms_records).to contain_exactly(draft)
        expect(view_object).to be_active_search
        expect(view_object.filter_form.email).to eq(
          " DRAFT-APPLICANT@EXAMPLE.COM ",
        )
      end
    end

    context "with only part of an email address" do
      let(:session) { { draft_filter_params: { email: "draft-applicant" } } }

      it "does not match partial addresses" do
        expect(view_object.application_forms_records).to be_empty
        expect(view_object.application_forms_pagy.count).to eq(0)
      end
    end

    context "with a whitespace-only search" do
      let(:session) { { draft_filter_params: { email: "   " } } }

      it "shows all drafts without an active search" do
        expect(view_object.application_forms_records).to contain_exactly(draft)
        expect(view_object).not_to be_active_search
      end
    end
  end

  describe "ordering and pagination" do
    let!(:drafts) do
      create_list(
        :application_form,
        21,
        region:,
        teacher:,
        created_at: 1.day.ago,
      )
    end

    it "paginates 20 records and counts every result" do
      expect(view_object.application_forms_pagy.limit).to eq(20)
      expect(view_object.application_forms_pagy.count).to eq(21)
      expect(view_object.application_forms_records).to eq(
        drafts.reverse.first(20),
      )
    end

    it "orders by draft creation before the ID tie-breaker" do
      drafts.first.update!(created_at: Time.current)
      drafts.last.update!(updated_at: 1.day.from_now)

      expect(view_object.application_forms_records.first).to eq(drafts.first)
    end

    context "on the next page of a search" do
      let(:params) { { page: "2" } }
      let(:session) { { draft_filter_params: { email: teacher.email } } }

      it "keeps the filter and returns the remaining result" do
        expect(view_object.application_forms_records).to eq([drafts.first])
        expect(view_object.application_forms_pagy.count).to eq(21)
        expect(view_object.filter_form.email).to eq(teacher.email)
      end
    end
  end

  describe "#summary_rows" do
    subject(:rows) { view_object.summary_rows(application_form) }

    let(:application_form) do
      build(
        :application_form,
        region:,
        given_names: "",
        family_name: "",
        created_at: Time.zone.local(2026, 5, 31, 12),
      )
    end

    it "presents exactly the four required fields" do
      expect(rows).to eq(
        [
          { key: { text: "Name" }, value: { text: "Not provided" } },
          { key: { text: "Country trained in" }, value: { text: "France" } },
          { key: { text: "Draft created" }, value: { text: "31 May 2026" } },
          { key: { text: "Days until deletion" }, value: { text: "6 days" } },
        ],
      )
    end

    it "shows the current name without changing the shared name fallback" do
      application_form.assign_attributes(
        given_names: "Example",
        family_name: "Applicant",
      )

      expect(rows.first[:value][:text]).to eq("Example Applicant")
    end

    it "shows a partially entered name" do
      application_form.family_name = "Applicant"

      expect(rows.first[:value][:text]).to eq("Applicant")
    end

    [[25, "1 day"], [24, "0 days"], [23, "0 days"]].each do |day, expected|
      it "shows #{expected} for a Draft created on 2026-05-#{day}" do
        application_form.created_at = Time.zone.local(2026, 5, day, 12)

        expect(rows.last[:value][:text]).to eq(expected)
      end
    end
  end
end
