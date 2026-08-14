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
        uk_within_10_day_sla =
          create :application_form,
                 :with_assessment,
                 :submitted,
                 region: uk_region
        create :prioritisation_work_history_check,
               assessment: uk_within_10_day_sla.assessment

        # UK within 40 & 80 day SLA
        create :application_form,
               :with_assessment,
               :submitted,
               region: uk_region

        # UK nearing 10 day SLA
        uk_nearing_10_day_sla =
          create :application_form,
                 :with_assessment,
                 :submitted,
                 region: uk_region,
                 working_days_between_submitted_and_today: 8
        create :prioritisation_work_history_check,
               assessment: uk_nearing_10_day_sla.assessment

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
        uk_breached_10_day_sla =
          create :application_form,
                 :with_assessment,
                 :submitted,
                 region: uk_region,
                 working_days_between_submitted_and_today: 10
        create :prioritisation_work_history_check,
               assessment: uk_breached_10_day_sla.assessment

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
        eu_within_10_day_sla =
          create :application_form,
                 :with_assessment,
                 :submitted,
                 region: france_region
        create :prioritisation_work_history_check,
               assessment: eu_within_10_day_sla.assessment

        # EU within 40 & 80 day SLA
        create :application_form,
               :with_assessment,
               :submitted,
               region: france_region

        # EU nearing 10 day SLA
        eu_nearing_10_day_sla =
          create :application_form,
                 :with_assessment,
                 :submitted,
                 region: france_region,
                 working_days_between_submitted_and_today: 8
        create :prioritisation_work_history_check,
               assessment: eu_nearing_10_day_sla.assessment

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
        eu_breached_10_day_sla =
          create :application_form,
                 :with_assessment,
                 :submitted,
                 region: france_region,
                 working_days_between_submitted_and_today: 10
        create :prioritisation_work_history_check,
               assessment: eu_breached_10_day_sla.assessment

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
        efta_within_10_day_sla =
          create :application_form,
                 :with_assessment,
                 :submitted,
                 region: switzerland_region
        create :prioritisation_work_history_check,
               assessment: efta_within_10_day_sla.assessment

        # EFTA within 40/80 day SLA
        create :application_form,
               :with_assessment,
               :submitted,
               region: switzerland_region

        # EFTA nearing 10 day SLA
        efta_nearing_10_day_sla =
          create :application_form,
                 :with_assessment,
                 :submitted,
                 region: switzerland_region,
                 working_days_between_submitted_and_today: 8
        create :prioritisation_work_history_check,
               assessment: efta_nearing_10_day_sla.assessment

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
        efta_breached_10_day_sla =
          create :application_form,
                 :with_assessment,
                 :submitted,
                 region: switzerland_region,
                 working_days_between_submitted_and_today: 10
        create :prioritisation_work_history_check,
               assessment: efta_breached_10_day_sla.assessment

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
        row_within_10_day_sla =
          create :application_form,
                 :with_assessment,
                 :submitted,
                 region: ghana_region
        create :prioritisation_work_history_check,
               assessment: row_within_10_day_sla.assessment

        # Rest of world within 40/80 day SLA
        create :application_form,
               :with_assessment,
               :submitted,
               region: ghana_region

        # Rest of world nearing 10 day SLA
        row_nearing_10_day_sla =
          create :application_form,
                 :with_assessment,
                 :submitted,
                 region: ghana_region,
                 working_days_between_submitted_and_today: 8
        create :prioritisation_work_history_check,
               assessment: row_nearing_10_day_sla.assessment

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
        row_breached_10_day_sla =
          create :application_form,
                 :with_assessment,
                 :submitted,
                 region: ghana_region,
                 working_days_between_submitted_and_today: 10
        create :prioritisation_work_history_check,
               assessment: row_breached_10_day_sla.assessment

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
