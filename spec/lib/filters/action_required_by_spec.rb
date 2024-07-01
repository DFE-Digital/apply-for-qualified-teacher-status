# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::ActionRequiredBy do
  subject(:filtered_scope) { described_class.apply(scope:, params:) }

  context "the params includes a action_required_by" do
    let(:params) { { action_required_by: "assessor" } }
    let(:scope) { ApplicationForm.all }

    let!(:included) { create(:application_form, :action_required_by_assessor) }

    before { create(:application_form, :action_required_by_admin) }

    it { is_expected.to contain_exactly(included) }
  end

  context "the params include multiple action_required_by" do
    let(:params) { { action_required_by: %w[assessor external] } }
    let(:scope) { ApplicationForm.all }

    let!(:included) { create(:application_form, :action_required_by_assessor) }

    before { create(:application_form, :action_required_by_admin) }

    it { is_expected.to contain_exactly(included) }
  end

  context "the params don't include action_required_by" do
    let(:params) { {} }
    let(:scope) { double }

    it { is_expected.to eq(scope) }
  end
end
