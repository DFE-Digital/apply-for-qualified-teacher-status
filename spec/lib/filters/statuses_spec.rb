# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::Statuses do
  subject(:filtered_scope) { described_class.apply(scope:, params:) }

  context "the params includes statuses" do
    let(:params) { { statuses: ["waiting_on_further_information"] } }
    let(:scope) { ApplicationForm.all }

    let!(:included) do
      create(
        :application_form,
        :submitted,
        statuses: ["waiting_on_further_information"],
      )
    end

    before do
      create(
        :application_form,
        :submitted,
        statuses: ["received_further_information"],
      )
    end

    it { is_expected.to contain_exactly(included) }

    context "with application form having multiple statuses" do
      let!(:included) do
        create(
          :application_form,
          :submitted,
          statuses: %w[preliminary_check waiting_on_further_information],
        )
      end

      it { is_expected.to contain_exactly(included) }
    end
  end

  context "the params include multiple statuses" do
    let(:params) do
      {
        statuses: %w[
          waiting_on_further_information
          received_further_information
        ],
      }
    end
    let(:scope) { ApplicationForm.all }

    let!(:included) do
      [
        create(
          :application_form,
          :submitted,
          statuses: ["waiting_on_further_information"],
        ),
        create(
          :application_form,
          :submitted,
          statuses: ["received_further_information"],
        ),
      ]
    end

    before { create(:application_form, :submitted) }

    it { is_expected.to match_array(included) }

    context "with application form having multiple statuses" do
      let!(:included) do
        [
          create(
            :application_form,
            :submitted,
            statuses: %w[preliminary_check waiting_on_further_information],
          ),
          create(
            :application_form,
            :submitted,
            statuses: ["received_further_information"],
          ),
        ]
      end

      it { is_expected.to match_array(included) }
    end
  end

  context "the params don't include statuses" do
    let(:params) { {} }
    let(:scope) { double }

    it { is_expected.to eq(scope) }
  end
end
