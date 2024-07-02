# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::Stage do
  subject(:filtered_scope) { described_class.apply(scope:, params:) }

  context "the params includes a stage" do
    let(:params) { { stage: "not_started" } }
    let(:scope) { ApplicationForm.all }

    let!(:included) { create(:application_form, :not_started_stage) }

    before { create(:application_form, :assessment_stage) }

    it { is_expected.to contain_exactly(included) }
  end

  context "the params include multiple stage" do
    let(:params) { { stage: %w[not_started assessment] } }
    let(:scope) { ApplicationForm.all }

    let!(:included) { create(:application_form, :not_started_stage) }

    before { create(:application_form, :completed_stage) }

    it { is_expected.to contain_exactly(included) }
  end

  context "the params don't include stage" do
    let(:params) { {} }
    let(:scope) { double }

    it { is_expected.to eq(scope) }
  end
end
