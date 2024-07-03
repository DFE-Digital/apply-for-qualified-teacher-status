# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::Reference do
  subject(:filtered_scope) { described_class.apply(scope:, params:) }

  context "the params include reference" do
    let(:params) { { reference: "ABC" } }
    let(:scope) { ApplicationForm.all }

    context "exact match" do
      let!(:included) { create(:application_form, reference: "ABC") }

      before { create(:application_form, reference: "XYZ") }

      it { is_expected.to contain_exactly(included) }
    end

    context "partial match" do
      let!(:included) { create(:application_form, reference: "ABCDEF") }

      before { create(:application_form, reference: "XYZ") }

      it { is_expected.to contain_exactly(included) }
    end

    context "match with different case" do
      let(:params) { { reference: "abc" } }

      let!(:included) { create(:application_form, reference: "ABC") }

      it { is_expected.to contain_exactly(included) }
    end
  end

  context "the params don't include reference" do
    let(:params) { {} }
    let(:scope) { double }

    it { is_expected.to eq(scope) }
  end

  context "with trailing whitespace" do
    let(:params) { { reference: "ABCDEF    " } }
    let(:scope) { ApplicationForm.all }
    let!(:included) { create(:application_form, reference: "ABCDEF") }

    before { create(:application_form, reference: "QRHGF") }

    it "returns a filtered scope" do
      expect(subject).to contain_exactly(included)
    end
  end

  context "with leading whitespace" do
    let(:params) { { reference: "    ABCDEF" } }
    let(:scope) { ApplicationForm.all }
    let!(:included) { create(:application_form, reference: "ABCDEF") }

    before { create(:application_form, reference: "QRHGF") }

    it "returns a filtered scope" do
      expect(subject).to contain_exactly(included)
    end
  end
end
