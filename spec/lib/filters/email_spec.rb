# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::Email do
  subject(:filtered_scope) { described_class.apply(scope:, params:) }

  context "the params include email" do
    let(:email) { "jane.smith@example.com" }
    let(:teacher) { create(:teacher, email:) }
    let(:params) { { email: } }
    let(:scope) { ApplicationForm.all }

    context "exact match" do
      let!(:included) { create(:application_form, teacher:) }

      before do
        create(
          :application_form,
          teacher: create(:teacher, email: "jane.jones@example.com"),
        )
      end

      it { is_expected.to contain_exactly(included) }
    end

    context "match with different case" do
      let(:params) { { email: "Jane.Smith@example.com" } }

      let!(:included) { create(:application_form, teacher:) }

      it { is_expected.to contain_exactly(included) }
    end

    context "with trailing whitespace" do
      let(:params) { { email: "Jane.Smith@example.com    " } }
      let(:scope) { ApplicationForm.all }
      let!(:included) { create(:application_form, teacher:) }

      before do
        create(
          :application_form,
          teacher: create(:teacher, email: "jane.jones@example.com"),
        )
      end

      it "returns a filtered scope" do
        expect(subject).to contain_exactly(included)
      end
    end

    context "with leading whitespace" do
      let(:params) { { email: "    Jane.Smith@example.com" } }
      let(:scope) { ApplicationForm.all }
      let!(:included) { create(:application_form, teacher:) }

      before do
        create(
          :application_form,
          teacher: create(:teacher, email: "jane.jones@example.com"),
        )
      end

      it "returns a filtered scope" do
        expect(subject).to contain_exactly(included)
      end
    end
  end

  context "the params don't include email" do
    let(:params) { {} }
    let(:scope) { double }

    it { is_expected.to eq(scope) }
  end
end
