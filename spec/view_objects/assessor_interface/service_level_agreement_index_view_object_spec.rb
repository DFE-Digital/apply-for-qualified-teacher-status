# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ServiceLevelAgreementIndexViewObject do
  subject(:view_object) { described_class.new(params:, session:) }

  let(:params) { {} }
  let(:session) { {} }

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

    let(:scope) { ApplicationForm.all }

    before do
      allow(Filters::SLA::TenDay).to receive(:apply).and_return(scope)
      allow(Filters::SLA::FortyDay).to receive(:apply).and_return(scope)
      allow(Filters::SLA::EightyDay).to receive(:apply).and_return(scope)

      allow(Filters::SLA::BreachStatuses).to receive(:apply).and_return(scope)
      allow(Filters::SLA::CountryGroupings).to receive(:apply).and_return(scope)
      allow(Filters::Flags).to receive(:apply).and_return(scope)
    end

    context "with no SLA param" do
      it "applies the ten-day filter" do
        application_forms_records

        expect(Filters::SLA::TenDay).to have_received(:apply).with(
          scope:,
          params:,
        )
        expect(Filters::SLA::BreachStatuses).to have_received(:apply).with(
          scope:,
          params: {
            sla: nil,
          },
        )
        expect(Filters::SLA::CountryGroupings).to have_received(:apply).with(
          scope:,
          params: {
            sla: nil,
          },
        )
        expect(Filters::Flags).to have_received(:apply).with(
          scope:,
          params: {
            sla: nil,
          },
        )
      end
    end

    context "when sla in params is 80" do
      let(:params) { { sla: "80" } }

      it "applies the eighty-day filter" do
        application_forms_records

        expect(Filters::SLA::EightyDay).to have_received(:apply).with(
          scope:,
          params: {
          },
        )
        expect(Filters::SLA::BreachStatuses).to have_received(:apply).with(
          scope:,
          params:,
        )
        expect(Filters::SLA::CountryGroupings).to have_received(:apply).with(
          scope:,
          params:,
        )
        expect(Filters::Flags).to have_received(:apply).with(scope:, params:)
      end
    end

    context "when sla in params is 40" do
      let(:params) { { sla: "40" } }

      it "applies the forty-day filter" do
        application_forms_records

        expect(Filters::SLA::FortyDay).to have_received(:apply).with(
          scope:,
          params: {
          },
        )
        expect(Filters::SLA::BreachStatuses).to have_received(:apply).with(
          scope:,
          params:,
        )
        expect(Filters::SLA::CountryGroupings).to have_received(:apply).with(
          scope:,
          params:,
        )
        expect(Filters::Flags).to have_received(:apply).with(scope:, params:)
      end
    end

    context "when sla in params is 10" do
      let(:params) { { sla: "10" } }

      it "applies the ten-day filter" do
        application_forms_records

        expect(Filters::SLA::TenDay).to have_received(:apply).with(
          scope:,
          params: {
          },
        )
        expect(Filters::SLA::BreachStatuses).to have_received(:apply).with(
          scope:,
          params:,
        )
        expect(Filters::SLA::CountryGroupings).to have_received(:apply).with(
          scope:,
          params:,
        )
        expect(Filters::Flags).to have_received(:apply).with(scope:, params:)
      end
    end
  end

  describe "#sla_working_day_tag_colour" do
    subject(:sla_working_day_tag_colour) do
      view_object.sla_working_day_tag_colour(application_form)
    end

    context "with no SLA param that defaults to the ten-day threshold" do
      context "when working days is at the threshold" do
        let(:application_form) do
          build :application_form, working_days_between_submitted_and_today: 10
        end

        it { is_expected.to eq("red") }
      end

      context "when working days is beyond the threshold" do
        let(:application_form) do
          build :application_form, working_days_between_submitted_and_today: 15
        end

        it { is_expected.to eq("red") }
      end

      context "when working days are below the threshold" do
        let(:application_form) do
          build :application_form, working_days_between_submitted_and_today: 9
        end

        it { is_expected.to eq("yellow") }
      end

      context "when working days is nil" do
        let(:application_form) { build :application_form }

        it { is_expected.to eq("yellow") }
      end
    end

    context "with the forty-day SLA" do
      let(:params) { { sla: "40" } }

      context "when working days is at the threshold" do
        let(:application_form) do
          build :application_form, working_days_between_submitted_and_today: 40
        end

        it { is_expected.to eq("red") }
      end

      context "when working days is beyond the threshold" do
        let(:application_form) do
          build :application_form, working_days_between_submitted_and_today: 45
        end

        it { is_expected.to eq("red") }
      end

      context "when working days are below the threshold" do
        let(:application_form) do
          build :application_form, working_days_between_submitted_and_today: 39
        end

        it { is_expected.to eq("yellow") }
      end

      context "when working days is nil" do
        let(:application_form) { build :application_form }

        it { is_expected.to eq("yellow") }
      end
    end

    context "with the eighty-day SLA" do
      let(:params) { { sla: "80" } }

      context "when working days are at the threshold" do
        let(:application_form) do
          build :application_form, working_days_between_submitted_and_today: 80
        end

        it { is_expected.to eq("red") }
      end

      context "when working days are at or beyond the threshold" do
        let(:application_form) do
          build :application_form, working_days_between_submitted_and_today: 85
        end

        it { is_expected.to eq("red") }
      end

      context "when working days are below the threshold" do
        let(:application_form) do
          build :application_form, working_days_between_submitted_and_today: 79
        end

        it { is_expected.to eq("yellow") }
      end

      context "when working days is nil" do
        let(:application_form) { build :application_form }

        it { is_expected.to eq("yellow") }
      end
    end
  end

  describe "#breach_statuses_options" do
    subject(:breach_statuses_options) { view_object.breach_statuses_options }

    it do
      expect(subject).to eq(
        [
          OpenStruct.new(id: "nearing", name: "Nearing"),
          OpenStruct.new(id: "breached", name: "Breached"),
        ],
      )
    end
  end

  describe "#country_groupings_options" do
    subject(:country_groupings_options) do
      view_object.country_groupings_options
    end

    it do
      expect(subject).to eq(
        [
          OpenStruct.new(id: "uk_and_gibraltar", name: "UK & Gibraltar"),
          OpenStruct.new(id: "eu", name: "EU"),
          OpenStruct.new(id: "efta", name: "EFTA"),
          OpenStruct.new(id: "rest_of_world", name: "Rest of the world"),
        ],
      )
    end
  end
end
