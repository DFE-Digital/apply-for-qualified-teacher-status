# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ServiceLevelAgreementTotalsViewObject do
  subject(:view_object) { described_class.new(params:) }

  let(:params) { {} }

  describe "#sla_counts" do
    it "returns zeros for every SLA when there are no applications" do
      expect(view_object.sla_counts).to eq(
        "10" => {
          nearing: 0,
          breached: 0,
        },
        "40" => {
          nearing: 0,
          breached: 0,
        },
        "80" => {
          nearing: 0,
          breached: 0,
        },
      )
    end

    context "when there are applications" do
      before do
        # UK/Gibraltar region example
        uk_region = create :region, :in_country, country_code: "GB-SCT"

        # EU region example
        france_region = create :region, :in_country, country_code: "FR"

        # EFTA
        switzerland_region = create :region, :in_country, country_code: "CH"

        # Rest of world
        ghana_region = create :region, :in_country, country_code: "GH"

        # UK within 10 day SLA
        create :application_form,
               :with_prioritisation_work_history_checks,
               region: uk_region

        # UK within 40 & 80 day SLA
        create :application_form,
               :with_assessment,
               :submitted,
               region: uk_region

        # UK nearing 10 day SLA
        create :application_form,
               :with_prioritisation_work_history_checks,
               region: uk_region,
               working_days_between_submitted_and_today: 8

        # UK nearing 40 day SLA
        create :application_form,
               :with_assessment,
               :submitted,
               region: uk_region,
               working_days_between_submitted_and_today: 35

        # UK nearing 80 day SLA - breaches 40 day SLA as well
        create :application_form,
               :with_assessment,
               :submitted,
               region: uk_region,
               working_days_between_submitted_and_today: 65

        # UK breached 10 day SLA
        create :application_form,
               :with_prioritisation_work_history_checks,
               region: uk_region,
               working_days_between_submitted_and_today: 10

        # UK breached 40 day SLA
        create :application_form,
               :with_assessment,
               :submitted,
               region: uk_region,
               working_days_between_submitted_and_today: 40

        # UK breached 80 day SLA - breaches 40 day SLA as well
        create :application_form,
               :with_assessment,
               :submitted,
               region: uk_region,
               working_days_between_submitted_and_today: 80

        # EU within 10 day SLA
        create :application_form,
               :with_prioritisation_work_history_checks,
               region: france_region

        # EU within 40 & 80 day SLA
        create :application_form,
               :with_assessment,
               :submitted,
               region: france_region

        # EU nearing 10 day SLA
        create :application_form,
               :with_prioritisation_work_history_checks,
               region: france_region,
               working_days_between_submitted_and_today: 8

        # EU nearing 40 day SLA
        create :application_form,
               :with_assessment,
               :submitted,
               region: france_region,
               working_days_between_submitted_and_today: 35

        # EU nearing 80 day SLA - breaches 40 day SLA as well
        create :application_form,
               :with_assessment,
               :submitted,
               region: france_region,
               working_days_between_submitted_and_today: 65

        # EU breached 10 day SLA
        create :application_form,
               :with_prioritisation_work_history_checks,
               region: france_region,
               working_days_between_submitted_and_today: 10

        # EU breached 40 day SLA
        create :application_form,
               :with_assessment,
               :submitted,
               region: france_region,
               working_days_between_submitted_and_today: 40

        # EU breached 80 day SLA - breaches 40 day SLA as well
        create :application_form,
               :with_assessment,
               :submitted,
               region: france_region,
               working_days_between_submitted_and_today: 80

        # EFTA within 10 day SLA
        create :application_form,
               :with_prioritisation_work_history_checks,
               region: switzerland_region

        # EFTA within 40/80 day SLA
        create :application_form,
               :with_assessment,
               :submitted,
               region: switzerland_region

        # EFTA nearing 10 day SLA
        create :application_form,
               :with_prioritisation_work_history_checks,
               region: switzerland_region,
               working_days_between_submitted_and_today: 8

        # EFTA nearing 40 day SLA
        create :application_form,
               :with_assessment,
               :submitted,
               region: switzerland_region,
               working_days_between_submitted_and_today: 35

        # EFTA nearing 80 day SLA - breaches 40 day SLA as well
        create :application_form,
               :with_assessment,
               :submitted,
               region: switzerland_region,
               working_days_between_submitted_and_today: 65

        # EFTA breached 10 day SLA
        create :application_form,
               :with_prioritisation_work_history_checks,
               region: switzerland_region,
               working_days_between_submitted_and_today: 10

        # EFTA breached 40 day SLA
        create :application_form,
               :with_assessment,
               :submitted,
               region: switzerland_region,
               working_days_between_submitted_and_today: 40

        # EFTA breached 80 day SLA - breaches 40 day SLA as well
        create :application_form,
               :with_assessment,
               :submitted,
               region: switzerland_region,
               working_days_between_submitted_and_today: 80

        # Rest of world within 10 day SLA
        create :application_form,
               :with_prioritisation_work_history_checks,
               region: ghana_region

        # Rest of world within 40/80 day SLA
        create :application_form,
               :with_assessment,
               :submitted,
               region: ghana_region

        # Rest of world nearing 10 day SLA
        create :application_form,
               :with_prioritisation_work_history_checks,
               region: ghana_region,
               working_days_between_submitted_and_today: 8

        # Rest of world nearing 40 day SLA
        create :application_form,
               :with_assessment,
               :submitted,
               region: ghana_region,
               working_days_between_submitted_and_today: 35

        # Rest of world nearing 80 day SLA - breaches 40 day SLA as well
        create :application_form,
               :with_assessment,
               :submitted,
               region: ghana_region,
               working_days_between_submitted_and_today: 65

        # Rest of world breached 10 day SLA
        create :application_form,
               :with_prioritisation_work_history_checks,
               region: ghana_region,
               working_days_between_submitted_and_today: 10

        # Rest of world breached 40 day SLA
        create :application_form,
               :with_assessment,
               :submitted,
               region: ghana_region,
               working_days_between_submitted_and_today: 40

        # Rest of world breached 80 day SLA - breaches 40 day SLA as well
        create :application_form,
               :with_assessment,
               :submitted,
               region: ghana_region,
               working_days_between_submitted_and_today: 80
      end

      it "returns correct values for every SLA without any params" do
        expect(view_object.sla_counts).to eq(
          "10" => {
            nearing: 4,
            breached: 4,
          },
          "40" => {
            nearing: 4,
            breached: 12,
          },
          "80" => {
            nearing: 4,
            breached: 4,
          },
        )
      end

      context "when params includes country_groupings as uk_and_gibraltar" do
        let(:params) { { country_groupings: "uk_and_gibraltar" } }

        it "returns correct values for UK & Gibraltar" do
          expect(view_object.sla_counts).to eq(
            "10" => {
              nearing: 1,
              breached: 1,
            },
            "40" => {
              nearing: 1,
              breached: 3,
            },
            "80" => {
              nearing: 1,
              breached: 1,
            },
          )
        end
      end

      context "when params includes country_groupings as eu" do
        let(:params) { { country_groupings: "eu" } }

        it "returns correct values for EU" do
          expect(view_object.sla_counts).to eq(
            "10" => {
              nearing: 1,
              breached: 1,
            },
            "40" => {
              nearing: 1,
              breached: 3,
            },
            "80" => {
              nearing: 1,
              breached: 1,
            },
          )
        end
      end

      context "when params includes country_groupings as efta" do
        let(:params) { { country_groupings: "efta" } }

        it "returns correct values for EFTA" do
          expect(view_object.sla_counts).to eq(
            "10" => {
              nearing: 1,
              breached: 1,
            },
            "40" => {
              nearing: 1,
              breached: 3,
            },
            "80" => {
              nearing: 1,
              breached: 1,
            },
          )
        end
      end

      context "when params includes country_groupings as rest_of_world" do
        let(:params) { { country_groupings: "rest_of_world" } }

        it "returns correct values for Rest of the world" do
          expect(view_object.sla_counts).to eq(
            "10" => {
              nearing: 1,
              breached: 1,
            },
            "40" => {
              nearing: 1,
              breached: 3,
            },
            "80" => {
              nearing: 1,
              breached: 1,
            },
          )
        end
      end
    end
  end
end
