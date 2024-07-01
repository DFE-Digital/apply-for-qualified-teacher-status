# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::Assessor do
  subject { described_class.apply(scope:, params:) }

  let(:assessor_one) { create(:staff) }
  let(:assessor_two) { create(:staff) }

  context "the params include assessor_id" do
    describe "filtering 'assessor'" do
      let(:params) { { assessor_ids: assessor_one.id } }
      let(:scope) { ApplicationForm.all }

      let!(:included) { create(:application_form, assessor: assessor_one) }

      before { create(:application_form, assessor: assessor_two) }

      it "returns a filtered scope" do
        expect(subject).to contain_exactly(included)
      end
    end

    describe "filtering 'reviewer'" do
      let(:params) { { assessor_ids: assessor_one.id } }
      let(:scope) { ApplicationForm.all }

      let!(:included) { create(:application_form, reviewer: assessor_one) }

      before { create(:application_form, reviewer: assessor_two) }

      it "returns a filtered scope" do
        expect(subject).to contain_exactly(included)
      end
    end
  end

  context "the params include multiple assessor_ids" do
    let(:params) { { assessor_ids: [assessor_one.id, assessor_two.id] } }
    let(:scope) { ApplicationForm.all }

    let!(:included) do
      [
        create(:application_form, assessor: assessor_one),
        create(:application_form, assessor: assessor_two),
      ]
    end

    before do
      create(:application_form)
      create(:application_form, assessor: create(:staff))
    end

    it "returns a filtered scope" do
      expect(subject).to match_array(included)
    end
  end

  context "the params include an unassigned null value" do
    let(:params) { { assessor_ids: ["null"] } }
    let(:scope) { ApplicationForm.all }

    let!(:included) { [create(:application_form)] }

    before { create(:application_form, assessor: create(:staff)) }

    it "returns a filtered scope" do
      expect(subject).to match_array(included)
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
