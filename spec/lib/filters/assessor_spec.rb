# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::Assessor do
  let(:assessor_one) { create(:staff) }
  let(:assessor_two) { create(:staff) }

  subject { described_class.apply(scope:, params:) }

  context "the params include assessor_id" do
    describe "filtering 'assigned to'" do
      let(:params) { { assessor_ids: assessor_one.id } }
      let(:scope) { ApplicationForm.all }

      let!(:included) { create(:application_form, assessor: assessor_one) }

      let!(:filtered) { create(:application_form, assessor: assessor_two) }

      it "returns a filtered scope" do
        expect(subject).to eq([included])
      end
    end

    describe "filtering 'reviewer'" do
      let(:params) { { assessor_ids: assessor_one.id } }
      let(:scope) { ApplicationForm.all }

      let!(:included) { create(:application_form, reviewer: assessor_one) }

      let!(:filtered) { create(:application_form, reviewer: assessor_two) }

      it "returns a filtered scope" do
        expect(subject).to eq([included])
      end
    end
  end

  context "the params include multiple assessor_ids" do
    let(:params) { { assessor_ids: [assessor_one.id, assessor_two.id] } }
    let(:scope) { ApplicationForm.all }

    let!(:included) do
      [
        create(:application_form, assessor: assessor_one),
        create(:application_form, assessor: assessor_two)
      ]
    end

    let!(:filtered) do
      create(:application_form)
      create(:application_form, assessor: create(:staff))
    end

    it "returns a filtered scope" do
      expect(subject).to eq(included)
    end
  end

  context "the params include a blank string" do
    let(:params) { { assessor_ids: [""] } }
    let(:scope) { double }

    it "returns the original scope" do
      expect(subject).to eq(scope)
    end
  end

  context "the params don't include :assessor_ids" do
    let(:params) { {} }
    let(:scope) { double }

    it "returns the original scope" do
      expect(subject).to eq(scope)
    end
  end
end
