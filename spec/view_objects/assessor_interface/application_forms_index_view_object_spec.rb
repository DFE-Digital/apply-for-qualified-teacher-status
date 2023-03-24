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

      context "with a status filter" do
        before do
          expect_any_instance_of(Filters::Status).to receive(:apply).and_return(
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
      let!(:staff) { create(:staff, :with_award_decline_permission) }

      it { is_expected.to include(staff) }
    end

    context "with an non-assessor user" do
      let!(:staff) { create(:staff) }

      it { is_expected.not_to include(staff) }
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
      let(:session) { { filter_params: { location: "country:US" } } }

      it do
        is_expected.to include(
          '<option selected="selected" value="country:US">United States</option>',
        )
      end
    end
  end

  describe "#status_filter_options" do
    subject(:status_filter_options) { view_object.status_filter_options }

    it do
      is_expected.to eq(
        [
          OpenStruct.new(
            id: "preliminary_check",
            label: "Preliminary check (0)",
          ),
          OpenStruct.new(id: "submitted", label: "Not started (0)"),
          OpenStruct.new(
            id: "initial_assessment",
            label: "Assessment in progress (0)",
          ),
          OpenStruct.new(id: "waiting_on", label: "Waiting on (0)"),
          OpenStruct.new(id: "received", label: "Received (0)"),
          OpenStruct.new(id: "overdue", label: "Overdue (0)"),
          OpenStruct.new(
            id: "awarded_pending_checks",
            label: "Award pending (0)",
          ),
          OpenStruct.new(id: "awarded", label: "Awarded (0)"),
          OpenStruct.new(id: "declined", label: "Declined (0)"),
          OpenStruct.new(
            id: "potential_duplicate_in_dqt",
            label: "Potential duplication in DQT (0)",
          ),
        ],
      )
    end

    context "with application forms" do
      before do
        create_list(:application_form, 1, :preliminary_check)
        create_list(:application_form, 2, :submitted)
        create_list(:application_form, 3, :initial_assessment)
        create_list(:application_form, 4, :waiting_on)
        create_list(:application_form, 5, :received)
        create_list(:application_form, 6, :overdue)
        create_list(:application_form, 7, :awarded_pending_checks)
        create_list(:application_form, 8, :awarded)
        create_list(:application_form, 9, :declined)
        create_list(:application_form, 10, :potential_duplicate_in_dqt)
      end

      it do
        is_expected.to eq(
          [
            OpenStruct.new(
              id: "preliminary_check",
              label: "Preliminary check (1)",
            ),
            OpenStruct.new(id: "submitted", label: "Not started (2)"),
            OpenStruct.new(
              id: "initial_assessment",
              label: "Assessment in progress (3)",
            ),
            OpenStruct.new(id: "waiting_on", label: "Waiting on (4)"),
            OpenStruct.new(id: "received", label: "Received (5)"),
            OpenStruct.new(id: "overdue", label: "Overdue (6)"),
            OpenStruct.new(
              id: "awarded_pending_checks",
              label: "Award pending (7)",
            ),
            OpenStruct.new(id: "awarded", label: "Awarded (8)"),
            OpenStruct.new(id: "declined", label: "Declined (9)"),
            OpenStruct.new(
              id: "potential_duplicate_in_dqt",
              label: "Potential duplication in DQT (10)",
            ),
          ],
        )
      end
    end
  end
end
