# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::SortBy do
  subject(:filtered_scope) { described_class.apply(scope:, params:) }

  let(:scope) { ApplicationForm.all }

  let!(:oldest) { create(:application_form, submitted_at: 3.days.ago) }
  let!(:middle) { create(:application_form, submitted_at: 2.days.ago) }
  let!(:newest) { create(:application_form, submitted_at: 1.day.ago) }

  context "when sort_by is 'submitted_at_asc'" do
    let(:params) { { sort_by: "submitted_at_asc" } }

    it { is_expected.to eq([oldest, middle, newest]) }
  end

  context "when sort_by is 'submitted_at_desc'" do
    let(:params) { { sort_by: "submitted_at_desc" } }

    it { is_expected.to eq([newest, middle, oldest]) }
  end

  context "when sort_by is not provided" do
    let(:params) { {} }

    it { is_expected.to eq([newest, middle, oldest]) }
  end
end
