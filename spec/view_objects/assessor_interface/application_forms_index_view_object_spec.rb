# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ApplicationFormsIndexViewObject do
  subject(:view_object) { described_class.new(params:, session:) }

  let(:params) { {} }
  let(:session) { {} }

  before { FeatureFlags::FeatureFlag.activate(:suitability) }

  after { FeatureFlags::FeatureFlag.deactivate(:suitability) }

  describe "#application_forms_pagy" do
    subject(:application_forms_pagy) { view_object.application_forms_pagy }

    it { is_expected.not_to be_nil }

    it "is configured correctly" do
      expect(application_forms_pagy.limit).to eq(20)
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
          allow_any_instance_of(Filters::Assessor).to receive(
            :apply,
          ).and_return(ApplicationForm.none)
        end

        it { is_expected.to be_empty }
      end

      context "with a country filter" do
        before do
          allow_any_instance_of(Filters::Country).to receive(:apply).and_return(
            ApplicationForm.none,
          )
        end

        it { is_expected.to be_empty }
      end

      context "with a name filter" do
        before do
          allow_any_instance_of(Filters::Name).to receive(:apply).and_return(
            ApplicationForm.none,
          )
        end

        it { is_expected.to be_empty }
      end

      context "with a reference filter" do
        before do
          allow_any_instance_of(Filters::Reference).to receive(
            :apply,
          ).and_return(ApplicationForm.none)
        end

        it { is_expected.to be_empty }
      end

      context "with a stage filter" do
        before do
          allow_any_instance_of(Filters::ShowAll).to receive(:apply).and_return(
            ApplicationForm.none,
          )
        end

        it { is_expected.to be_empty }
      end

      context "with a statuses filter" do
        before do
          allow_any_instance_of(Filters::Statuses).to receive(
            :apply,
          ).and_return(ApplicationForm.none)
        end

        it { is_expected.to be_empty }
      end

      context "with show all filter" do
        before do
          allow_any_instance_of(Filters::Stage).to receive(:apply).and_return(
            ApplicationForm.none,
          )
        end

        it { is_expected.to be_empty }
      end
    end

    context "default sorting newest to oldest" do
      let!(:oldest) do
        create(
          :application_form,
          :submitted,
          submitted_at: Date.new(2020, 1, 1),
        )
      end

      let!(:newest) do
        create(
          :application_form,
          :submitted,
          submitted_at: Date.new(2020, 1, 2),
        )
      end

      it { is_expected.to eq([newest, oldest]) }

      context "when sorted by oldest to newest" do
        let(:session) { { sort_params: { sort_by: "submitted_at_asc" } } }

        it { is_expected.to eq([oldest, newest]) }
      end
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
      expect(subject).to include(
        OpenStruct.new(id: "null", name: "Not assigned"),
      )
    end

    context "with an assessor user" do
      let!(:staff) { create(:staff) }

      before { create(:application_form, :submitted, assessor: staff) }

      it do
        expect(subject).to include(
          OpenStruct.new(id: staff.id, name: staff.name),
        )
      end
    end

    context "with an non-assessor user" do
      let!(:staff) { create(:staff) }

      it do
        expect(subject).not_to include(
          OpenStruct.new(id: staff.id, name: staff.name),
        )
      end
    end

    context "with an archived assessor user" do
      let!(:staff) { create(:staff, archived: true) }

      it do
        expect(subject).not_to include(
          OpenStruct.new(id: staff.id, name: staff.name),
        )
      end
    end
  end

  describe "#country_filter_options" do
    subject(:country_filter_options) { view_object.country_filter_options }

    it do
      expect(subject).to include(
        '<option value="country:US">United States</option>',
      )
    end

    context "when the filter is set" do
      let(:session) { { filter_params: { location: "country:US" } } }

      it do
        expect(subject).to include(
          '<option selected="selected" value="country:US">United States</option>',
        )
      end
    end
  end

  describe "#stage_filter_options" do
    subject(:stage_filter_options) { view_object.stage_filter_options }

    it do
      expect(subject).to eq(
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
        expect(subject).to eq(
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

  describe "#status_filter_options" do
    subject(:status_filter_options) { view_object.status_filter_options }

    it do
      expect(subject).to eq(
        [
          OpenStruct.new(
            id: "assessment_in_progress",
            label: "Assessment in progress",
          ),
          OpenStruct.new(
            id: "assessment_not_started",
            label: "Assessment not started",
          ),
          OpenStruct.new(id: "awarded_pending_checks", label: "Award pending"),
          OpenStruct.new(id: "awarded", label: "Awarded"),
          OpenStruct.new(id: "declined", label: "Declined"),
          OpenStruct.new(id: "overdue_ecctis", label: "Overdue Ecctis"),
          OpenStruct.new(id: "overdue_lops", label: "Overdue LoPS"),
          OpenStruct.new(id: "overdue_consent", label: "Overdue consent"),
          OpenStruct.new(
            id: "overdue_prioritisation_reference",
            label: "Overdue prioritisation reference",
          ),
          OpenStruct.new(id: "overdue_reference", label: "Overdue reference"),
          OpenStruct.new(
            id: "potential_duplicate_in_dqt",
            label: "Potential duplication in TRS",
          ),
          OpenStruct.new(id: "preliminary_check", label: "Preliminary check"),
          OpenStruct.new(
            id: "prioritisation_check",
            label: "Prioritisation check",
          ),
          OpenStruct.new(id: "received_consent", label: "Received consent"),
          OpenStruct.new(
            id: "received_further_information",
            label: "Received further information",
          ),
          OpenStruct.new(
            id: "received_prioritisation_reference",
            label: "Received prioritisation reference",
          ),
          OpenStruct.new(id: "received_reference", label: "Received reference"),
          OpenStruct.new(id: "review", label: "Review"),
          OpenStruct.new(
            id: "verification_in_progress",
            label: "Verification in progress",
          ),
          OpenStruct.new(id: "waiting_on_ecctis", label: "Waiting on Ecctis"),
          OpenStruct.new(id: "waiting_on_lops", label: "Waiting on LoPS"),
          OpenStruct.new(id: "waiting_on_consent", label: "Waiting on consent"),
          OpenStruct.new(
            id: "waiting_on_further_information",
            label: "Waiting on further information",
          ),
          OpenStruct.new(
            id: "waiting_on_prioritisation_reference",
            label: "Waiting on prioritisation reference",
          ),
          OpenStruct.new(
            id: "waiting_on_reference",
            label: "Waiting on reference",
          ),
          OpenStruct.new(id: "withdrawn", label: "Withdrawn"),
        ],
      )
    end
  end

  describe "#prioritised_filter_option_label" do
    subject(:prioritised_filter_option_label) do
      view_object.prioritised_filter_option_label
    end

    it { expect(subject).to eq("Prioritised (0)") }

    context "when there are application forms" do
      before do
        non_prioritised_application_form = create(:application_form, :submitted)
        create :assessment,
               application_form: non_prioritised_application_form,
               prioritised: false

        prioritised_application_form = create(:application_form, :submitted)
        create :assessment,
               application_form: prioritised_application_form,
               prioritised: true
      end

      it { expect(subject).to eq("Prioritised (1)") }
    end
  end
end
