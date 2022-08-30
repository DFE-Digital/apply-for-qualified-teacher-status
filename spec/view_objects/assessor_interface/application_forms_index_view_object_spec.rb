# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ApplicationFormsIndexViewObject do
  subject(:view_object) { described_class.new(params:) }

  let(:params) { {} }

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

      context "with a name filter" do
        before do
          expect_any_instance_of(Filters::Name).to receive(:apply).and_return(
            ApplicationForm.none
          )
        end

        it { is_expected.to be_empty }
      end

      context "with an assessor filter" do
        before do
          expect_any_instance_of(Filters::Assessor).to receive(
            :apply
          ).and_return(ApplicationForm.none)
        end

        it { is_expected.to be_empty }
      end

      context "with a country filter" do
        before do
          expect_any_instance_of(Filters::Country).to receive(
            :apply
          ).and_return(ApplicationForm.none)
        end

        it { is_expected.to be_empty }
      end

      context "with a state filter" do
        before do
          expect_any_instance_of(Filters::State).to receive(:apply).and_return(
            ApplicationForm.none
          )
        end

        it { is_expected.to be_empty }
      end
    end

    context "with multiple application forms" do
      let(:application_form_1) do
        create(:application_form, :submitted, created_at: Date.new(2020, 1, 1))
      end
      let(:application_form_2) do
        create(:application_form, :submitted, created_at: Date.new(2020, 1, 2))
      end

      it { is_expected.to eq([application_form_2, application_form_1]) }
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

    it { is_expected.to be_empty }

    context "with a staff user" do
      let(:staff) { create(:staff) }

      it { is_expected.to include(staff) }
    end
  end

  describe "#assessor_filter_checked?" do
    subject(:assessor_filter_checked?) do
      view_object.assessor_filter_checked?(option)
    end

    let(:option) { OpenStruct.new(id: 1) }

    it { is_expected.to be false }

    context "when the filter is set" do
      let(:params) { { assessor_ids: %w[1] } }

      it { is_expected.to be true }
    end
  end

  describe "#country_filter_options" do
    subject(:country_filter_options) { view_object.country_filter_options }

    it do
      is_expected.to include(
        '<option value="country:US">United States</option>'
      )
    end

    context "when the filter is set" do
      let(:params) { { location: "country:US" } }

      it do
        is_expected.to include(
          '<option selected="selected" value="country:US">United States</option>'
        )
      end
    end
  end

  describe "#name_filter_value" do
    subject(:name_filter_value) { view_object.name_filter_value }

    it { is_expected.to be_nil }

    context "when the filter is set" do
      let(:params) { { name: "abc" } }

      it { is_expected.to eq("abc") }
    end
  end

  describe "#state_filter_options" do
    subject(:state_filter_options) { view_object.state_filter_options }

    it do
      is_expected.to eq(
        [
          OpenStruct.new(id: "submitted", label: "Submitted (0)"),
          OpenStruct.new(id: "awarded", label: "Awarded (0)"),
          OpenStruct.new(id: "declined", label: "Declined (0)")
        ]
      )
    end

    context "with application forms" do
      before do
        create_list(:application_form, 2, :submitted)
        create_list(:application_form, 3, :awarded)
        create_list(:application_form, 4, :declined)
      end

      it do
        is_expected.to eq(
          [
            OpenStruct.new(id: "submitted", label: "Submitted (2)"),
            OpenStruct.new(id: "awarded", label: "Awarded (3)"),
            OpenStruct.new(id: "declined", label: "Declined (4)")
          ]
        )
      end
    end
  end

  describe "#state_filter_checked?" do
    subject(:state_filter_checked?) do
      view_object.state_filter_checked?(option)
    end

    let(:option) { OpenStruct.new(id: "draft") }

    it { is_expected.to be false }

    context "when the filter is set" do
      let(:params) { { states: %w[draft submitted] } }

      it { is_expected.to be true }
    end
  end
end
