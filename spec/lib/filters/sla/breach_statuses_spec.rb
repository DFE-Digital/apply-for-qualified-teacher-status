# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::SLA::BreachStatuses do
  subject(:filtered_scope) { described_class.apply(scope:, params:) }

  let(:scope) { ApplicationForm.all }

  context "when no breach statuses are given" do
    context "with the key absent" do
      let(:params) { {} }

      it { is_expected.to eq(scope) }
    end

    context "with the values blank" do
      let(:params) { { breach_statuses: ["", nil] } }

      it { is_expected.to eq(scope) }
    end
  end

  context "when filtering by breach status for 10 days" do
    let!(:nearing) do
      create(:application_form, working_days_between_submitted_and_today: 8)
    end

    let!(:breached) do
      create(:application_form, working_days_between_submitted_and_today: 10)
    end

    before do
      # Below nearing
      create(:application_form, working_days_between_submitted_and_today: 7)
    end

    context "with only nearing" do
      let(:params) { { breach_statuses: %w[nearing] } }

      it { is_expected.to contain_exactly(nearing) }
    end

    context "with only breached" do
      let(:params) { { breach_statuses: %w[breached] } }

      it { is_expected.to contain_exactly(breached) }
    end

    context "with both nearing and breached" do
      let(:params) { { breach_statuses: %w[nearing breached] } }

      it { is_expected.to contain_exactly(nearing, breached) }
    end
  end

  context "when filtering by breach status for 40 days" do
    let!(:nearing) do
      create(:application_form, working_days_between_submitted_and_today: 35)
    end

    let!(:breached) do
      create(:application_form, working_days_between_submitted_and_today: 40)
    end

    before do
      # Below nearing
      create(:application_form, working_days_between_submitted_and_today: 34)
    end

    context "with only nearing" do
      let(:params) { { sla: "40", breach_statuses: %w[nearing] } }

      it { is_expected.to contain_exactly(nearing) }
    end

    context "with only breached" do
      let(:params) { { sla: "40", breach_statuses: %w[breached] } }

      it { is_expected.to contain_exactly(breached) }
    end

    context "with both nearing and breached" do
      let(:params) { { sla: "40", breach_statuses: %w[nearing breached] } }

      it { is_expected.to contain_exactly(nearing, breached) }
    end
  end

  context "when filtering by breach status for 80 days" do
    let!(:nearing) do
      create(:application_form, working_days_between_submitted_and_today: 65)
    end

    let!(:breached) do
      create(:application_form, working_days_between_submitted_and_today: 80)
    end

    before do
      # Below nearing
      create(:application_form, working_days_between_submitted_and_today: 60)
    end

    context "with only nearing" do
      let(:params) { { sla: "80", breach_statuses: %w[nearing] } }

      it { is_expected.to contain_exactly(nearing) }
    end

    context "with only breached" do
      let(:params) { { sla: "80", breach_statuses: %w[breached] } }

      it { is_expected.to contain_exactly(breached) }
    end

    context "with both nearing and breached" do
      let(:params) { { sla: "80", breach_statuses: %w[nearing breached] } }

      it { is_expected.to contain_exactly(nearing, breached) }
    end
  end
end
