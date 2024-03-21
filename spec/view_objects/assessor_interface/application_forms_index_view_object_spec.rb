# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ApplicationFormsIndexViewObject do
  subject(:view_object) { described_class.new(params:, session:) }

  let(:params) { {} }
  let(:session) { {} }

  describe "#application_forms_pagy" do
    subject(:application_forms_pagy) { view_object.application_forms_pagy }

    it { is_expected.to_not be_nil }

    it "is configured correctly" do
      expect(application_forms_pagy.items).to eq(20)
      expect(application_forms_pagy.page).to eq(1)
    end
  end

  describe "#application_forms_records" do
    subject(:application_forms_records) do
      view_object.application_forms_records
    end

    it { is_expected.to be_empty }

    context "with an active application form" do
      let!(:application_form) { create(:application_form, :submitted) }

      it { is_expected.to include(application_form) }

      context "with an assessor filter" do
        before do
          expect_any_instance_of(Filters::Assessor).to receive(
            :apply,
          ).and_return(ApplicationForm.none)
        end

        it { is_expected.to be_empty }
      end

      context "with a country filter" do
        before do
          expect_any_instance_of(Filters::Country).to receive(
            :apply,
          ).and_return(ApplicationForm.none)
        end

        it { is_expected.to be_empty }
      end

      context "with a name filter" do
        before do
          expect_any_instance_of(Filters::Name).to receive(:apply).and_return(
            ApplicationForm.none,
          )
        end

        it { is_expected.to be_empty }
      end

      context "with a reference filter" do
        before do
          expect_any_instance_of(Filters::Reference).to receive(
            :apply,
          ).and_return(ApplicationForm.none)
        end

        it { is_expected.to be_empty }
      end

      context "with an action required by filter" do
        before do
          expect_any_instance_of(Filters::ActionRequiredBy).to receive(
            :apply,
          ).and_return(ApplicationForm.none)
        end

        it { is_expected.to be_empty }
      end

      context "with a stage filter" do
        before do
          expect_any_instance_of(Filters::ShowAllApplications).to receive(
            :apply,
          ).and_return(ApplicationForm.none)
        end

        it { is_expected.to be_empty }
      end

      context "with show all filter" do
        before do
          expect_any_instance_of(Filters::Stage).to receive(:apply).and_return(
            ApplicationForm.none,
          )
        end

        it { is_expected.to be_empty }
      end
    end

    context "with multiple application forms" do
      let(:application_form_1) do
        create(
          :application_form,
          :submitted,
          submitted_at: Date.new(2020, 1, 1),
        )
      end
      let(:application_form_2) do
        create(
          :application_form,
          :submitted,
          submitted_at: Date.new(2020, 1, 2),
        )
      end

      it { is_expected.to eq([application_form_1, application_form_2]) }
    end

    context "with lots of application forms" do
      before { create_list(:application_form, 25, :submitted) }

      it "limits to 20 results" do
        expect(application_forms_records.length).to eq(20)
      end
    end
  end

  describe "#assessor_filter_options" do
    subject(:assessor_filter_options) { view_object.assessor_filter_options }

    it do
      is_expected.to include(OpenStruct.new(id: "null", name: "Not assigned"))
    end

    context "with an assessor user" do
      let!(:staff) { create(:staff) }

      before { create(:application_form, :submitted, assessor: staff) }

      it do
        is_expected.to include(OpenStruct.new(id: staff.id, name: staff.name))
      end
    end

    context "with an non-assessor user" do
      let!(:staff) { create(:staff) }

      it do
        is_expected.to_not include(
          OpenStruct.new(id: staff.id, name: staff.name),
        )
      end
    end
  end

  describe "#country_filter_options" do
    it do
      is_expected.to include(
        '<option value="country:US">United States</option>',
      )
    end

    context "when the filter is set" do
      let(:session) { { filter_params: { location: "country:US" } } }

      it do
        is_expected.to include(
          '<option selected="selected" value="country:US">United States</option>',
        )
      end
    end
  end

  describe "#stage_filter_options" do
    subject(:stage_filter_options) { view_object.stage_filter_options }

    it do
      is_expected.to eq(
        [
          OpenStruct.new(id: "pre_assessment", label: "Pre-assessment (0)"),
          OpenStruct.new(id: "not_started", label: "Not started (0)"),
          OpenStruct.new(id: "assessment", label: "Assessment (0)"),
          OpenStruct.new(id: "verification", label: "Verification (0)"),
          OpenStruct.new(id: "review", label: "Review (0)"),
          OpenStruct.new(id: "completed", label: "Completed (0)"),
        ],
      )
    end

    context "with application forms" do
      before do
        create_list(:application_form, 1, :submitted, :pre_assessment_stage)
        create_list(:application_form, 2, :submitted, :not_started_stage)
        create_list(:application_form, 3, :submitted, :assessment_stage)
        create_list(:application_form, 4, :submitted, :verification_stage)
        create_list(:application_form, 5, :submitted, :review_stage)
        create_list(:application_form, 6, :awarded, :completed_stage)
      end

      it do
        is_expected.to eq(
          [
            OpenStruct.new(id: "pre_assessment", label: "Pre-assessment (1)"),
            OpenStruct.new(id: "not_started", label: "Not started (2)"),
            OpenStruct.new(id: "assessment", label: "Assessment (3)"),
            OpenStruct.new(id: "verification", label: "Verification (4)"),
            OpenStruct.new(id: "review", label: "Review (5)"),
            OpenStruct.new(id: "completed", label: "Completed (6)"),
          ],
        )
      end
    end
  end
end
