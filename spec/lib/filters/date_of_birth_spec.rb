# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::DateOfBirth do
  subject { described_class.apply(scope:, params:) }

  context "with date_of_birth params" do
    let(:params) do
      {
        "date_of_birth(1i)" => "1990",
        "date_of_birth(2i)" => "03",
        "date_of_birth(3i)" => "15",
      }
    end
    let(:scope) { ApplicationForm.all }

    let!(:included) do
      create(:application_form, date_of_birth: Date.new(1990, 3, 15))
    end

    before do
      create(:application_form, date_of_birth: Date.new(1990, 3, 14))
      create(:application_form, date_of_birth: Date.new(1990, 3, 16))
      create(:application_form, date_of_birth: Date.new(1985, 3, 15))
      create(:application_form, date_of_birth: nil)
    end

    it { is_expected.to contain_exactly(included) }
  end

  context "with invalid date params" do
    let(:params) do
      {
        "date_of_birth(1i)" => "2020",
        "date_of_birth(2i)" => "02",
        "date_of_birth(3i)" => "30", # Invalid: Feb 30th doesn't exist
      }
    end
    let(:scope) { ApplicationForm.all }

    before { create(:application_form, date_of_birth: Date.new(1990, 1, 1)) }

    it "returns unfiltered scope when date is invalid" do
      expect(subject).to eq(scope)
    end
  end

  context "without date_of_birth params" do
    let(:params) { {} }
    let(:scope) { double }

    it { is_expected.to eq(scope) }
  end

  context "with partial date params" do
    let(:params) do
      {
        "date_of_birth(1i)" => "1990",
        "date_of_birth(2i)" => "03",
        # Missing day parameter
      }
    end
    let(:scope) { ApplicationForm.all }

    before { create(:application_form, date_of_birth: Date.new(1990, 3, 15)) }

    it "returns unfiltered scope when date params are incomplete" do
      expect(subject).to eq(scope)
    end
  end
end
