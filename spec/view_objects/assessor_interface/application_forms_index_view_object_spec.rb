# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ApplicationFormsIndexViewObject do
  subject(:view_object) do
    described_class.new(params: ActionController::Parameters.new(params))
  end

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

      context "with a state filter" do
        before do
          expect_any_instance_of(Filters::State).to receive(:apply).and_return(
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

    it { is_expected.to be_empty }

    context "with a staff user" do
      let(:staff) { create(:staff) }

      it { is_expected.to include(staff) }
    end
  end

  describe "#country_filter_options" do
    subject(:country_filter_options) { view_object.country_filter_options }

    it do
      is_expected.to include(
        '<option value="country:US">United States</option>',
      )
    end

    context "when the filter is set" do
      let(:params) do
        {
          assessor_interface_filter_form: {
            location: "country:US",
          },
          location_autocomplete: "United States",
        }
      end

      it do
        is_expected.to include(
          '<option selected="selected" value="country:US">United States</option>',
        )
      end
    end

    context "when the autocomplete input is cleared" do
      let(:params) do
        {
          assessor_interface_filter_form: {
            location: "country:US",
          },
          location_autocomplete: "",
        }
      end

      it do
        is_expected.to include(
          '<option value="country:US">United States</option>',
        )
      end
    end

    context "when the autocomplete input isn't being used" do
      let(:params) do
        { assessor_interface_filter_form: { location: "country:US" } }
      end

      it do
        is_expected.to include(
          '<option selected="selected" value="country:US">United States</option>',
        )
      end
    end
  end

  describe "#state_filter_options" do
    subject(:state_filter_options) { view_object.state_filter_options }

    it do
      is_expected.to eq(
        [
          OpenStruct.new(id: "submitted", label: "Not started (0)"),
          OpenStruct.new(
            id: "initial_assessment",
            label: "Initial assessment (0)",
          ),
          OpenStruct.new(
            id: "further_information_requested",
            label: "Further information requested (0)",
          ),
          OpenStruct.new(
            id: "further_information_received",
            label: "Further information received (0)",
          ),
          OpenStruct.new(id: "awarded", label: "Awarded (0)"),
          OpenStruct.new(id: "declined", label: "Declined (0)"),
        ],
      )
    end

    context "with application forms" do
      before do
        create_list(:application_form, 1, :submitted)
        create_list(:application_form, 2, :initial_assessment)
        create_list(:application_form, 3, :further_information_requested)
        create_list(:application_form, 4, :further_information_received)
        create_list(:application_form, 5, :awarded)
        create_list(:application_form, 6, :declined)
      end

      it do
        is_expected.to eq(
          [
            OpenStruct.new(id: "submitted", label: "Not started (1)"),
            OpenStruct.new(
              id: "initial_assessment",
              label: "Initial assessment (2)",
            ),
            OpenStruct.new(
              id: "further_information_requested",
              label: "Further information requested (3)",
            ),
            OpenStruct.new(
              id: "further_information_received",
              label: "Further information received (4)",
            ),
            OpenStruct.new(id: "awarded", label: "Awarded (5)"),
            OpenStruct.new(id: "declined", label: "Declined (6)"),
          ],
        )
      end
    end
  end

  describe "#permitted_params" do
    subject(:permitted_params) { view_object.permitted_params }

    it { is_expected.to be_empty }

    context "with permitted params" do
      let(:params) do
        {
          assessor_interface_filter_form: {
            assessor_ids: ["assessor_id"],
            location: "location",
            name: "name",
            reference: "reference",
            states: ["state"],
          },
          location_autocomplete: "location_autocomplete",
          page: "page",
        }
      end

      it do
        is_expected.to eq(
          {
            "assessor_interface_filter_form" => {
              "assessor_ids" => ["assessor_id"],
              "location" => "location",
              "name" => "name",
              "reference" => "reference",
              "states" => ["state"],
            },
            "location_autocomplete" => "location_autocomplete",
            "page" => "page",
          },
        )
      end
    end

    context "with unpermitted params" do
      let(:params) { { unpermitted: "unpermitted" } }

      it { is_expected.to be_empty }
    end
  end
end
