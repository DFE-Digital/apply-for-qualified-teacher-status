# frozen_string_literal: true

require "rails_helper"

RSpec.describe PrioritisationWorkHistoryChecksFactory do
  describe "#call" do
    subject(:prioritisation_work_history_checks) do
      described_class.call(application_form:)
    end

    let(:application_form) do
      create :application_form, includes_prioritisation_features:
    end

    context "when the application form doesn't include prioritisation features" do
      let(:includes_prioritisation_features) { false }

      context "with the application form having work history not from England within last 12 months" do
        before do
          create :work_history,
                 :completed,
                 country_code: "UA",
                 still_employed: false,
                 start_date: 3.years.ago,
                 end_date: 3.months.ago,
                 application_form:
        end

        it { is_expected.to be_empty }
      end

      context "with the application form having work history from England over 12 months ago" do
        before do
          create :work_history,
                 :completed,
                 country_code: "GB-ENG",
                 still_employed: false,
                 start_date: 3.years.ago,
                 end_date: 2.years.ago,
                 application_form:
        end

        it { is_expected.to be_empty }
      end

      context "with the application form having work history from England ending within last 12 months" do
        before do
          create :work_history,
                 :completed,
                 country_code: "GB-ENG",
                 still_employed: false,
                 start_date: 3.years.ago,
                 end_date: 3.months.ago,
                 application_form:
        end

        it { is_expected.to be_empty }
      end

      context "with the application form having work history from England as current role" do
        before do
          create :work_history, :current_role_in_england, application_form:
        end

        it { is_expected.to be_empty }
      end
    end

    context "when the application form includes prioritisation features" do
      let(:includes_prioritisation_features) { true }

      context "with the application form having work history not from England within last 12 months" do
        before do
          create :work_history,
                 :completed,
                 country_code: "UA",
                 still_employed: false,
                 start_date: 3.years.ago,
                 end_date: 3.months.ago,
                 application_form:
        end

        it { is_expected.to be_empty }
      end

      context "with the application form having work history from England over 12 months ago" do
        before do
          create :work_history,
                 :completed,
                 country_code: "GB-ENG",
                 still_employed: false,
                 start_date: 3.years.ago,
                 end_date: 2.years.ago,
                 application_form:
        end

        it { is_expected.to be_empty }
      end

      context "with the application form having work history from England ending within last 12 months" do
        let!(:work_history) do
          create :work_history,
                 :completed,
                 country_code: "GB-ENG",
                 still_employed: false,
                 start_date: 3.years.ago,
                 end_date: 3.months.ago,
                 application_form:
        end

        it { is_expected.not_to be_empty }

        it "has the right checks and failure reasons" do
          prioritisation_work_history_check =
            prioritisation_work_history_checks.first
          expect(prioritisation_work_history_check.checks).to eq %w[
               prioritisation_work_history_role
               prioritisation_work_history_setting
               prioritisation_work_history_in_england
               prioritisation_work_history_reference_email
               prioritisation_work_history_reference_job
             ]
          expect(prioritisation_work_history_check.failure_reasons).to eq %w[
               prioritisation_work_history_role
               prioritisation_work_history_setting
               prioritisation_work_history_in_england
               prioritisation_work_history_institution_not_found
               prioritisation_work_history_reference_email
               prioritisation_work_history_reference_job
             ]
          expect(prioritisation_work_history_check.work_history).to eq(
            work_history,
          )
        end
      end

      context "with the application form having work history from England as current role" do
        let!(:work_history) do
          create :work_history, :current_role_in_england, application_form:
        end

        it { is_expected.not_to be_empty }

        it "has the right checks and failure reasons and work history" do
          prioritisation_work_history_check =
            prioritisation_work_history_checks.first
          expect(prioritisation_work_history_check.checks).to eq %w[
               prioritisation_work_history_role
               prioritisation_work_history_setting
               prioritisation_work_history_in_england
               prioritisation_work_history_reference_email
               prioritisation_work_history_reference_job
             ]
          expect(prioritisation_work_history_check.failure_reasons).to eq %w[
               prioritisation_work_history_role
               prioritisation_work_history_setting
               prioritisation_work_history_in_england
               prioritisation_work_history_institution_not_found
               prioritisation_work_history_reference_email
               prioritisation_work_history_reference_job
             ]
          expect(prioritisation_work_history_check.work_history).to eq(
            work_history,
          )
        end
      end
    end
  end
end
