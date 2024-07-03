# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::SubmittedAt do
  subject { described_class.apply(scope:, params:) }

  context "with both submitted_at params" do
    let(:params) do
      {
        "submitted_at_after(1i)" => "2020",
        "submitted_at_after(2i)" => "01",
        "submitted_at_after(3i)" => "01",
        "submitted_at_before(1i)" => "2020",
        "submitted_at_before(2i)" => "01",
        "submitted_at_before(3i)" => "31",
      }
    end
    let(:scope) { ApplicationForm.all }

    let!(:included) do
      create(:application_form, submitted_at: Date.new(2020, 1, 10))
    end

    before do
      create(:application_form, :submitted, submitted_at: Date.new(2019, 1, 1))
      create(:application_form, :submitted, submitted_at: Date.new(2021, 1, 1))
    end

    it { is_expected.to contain_exactly(included) }
  end

  context "with submitted_at before param" do
    let(:params) do
      {
        "submitted_at_before(1i)" => "2020",
        "submitted_at_before(2i)" => "01",
        "submitted_at_before(3i)" => "01",
      }
    end
    let(:scope) { ApplicationForm.all }

    let!(:included) do
      create(:application_form, submitted_at: Date.new(2020, 1, 1))
    end

    before do
      create(:application_form, :submitted, submitted_at: Date.new(2020, 1, 2))
    end

    it { is_expected.to contain_exactly(included) }
  end

  context "with submitted_at after param" do
    let(:params) do
      {
        "submitted_at_after(1i)" => "2020",
        "submitted_at_after(2i)" => "01",
        "submitted_at_after(3i)" => "02",
      }
    end
    let(:scope) { ApplicationForm.all }

    let!(:included) do
      create(:application_form, submitted_at: Date.new(2020, 1, 2))
    end

    before do
      create(:application_form, :submitted, submitted_at: Date.new(2020, 1, 1))
    end

    it { is_expected.to contain_exactly(included) }
  end

  context "without submitted_at params" do
    let(:params) { {} }
    let(:scope) { double }

    it { is_expected.to eq(scope) }
  end
end
