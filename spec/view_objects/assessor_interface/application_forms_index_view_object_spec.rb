# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ApplicationFormsIndexViewObject do
  subject(:view_object) { described_class.new(params:) }

  let(:params) { {} }

  describe "#application_forms" do
    subject(:application_forms) { view_object.application_forms }

    it { is_expected.to be_empty }

    context "with an active application form" do
      let!(:application_form) { create(:application_form, :submitted) }

      it { is_expected.to include(application_form) }

      it "filters on the name" do
        expect_any_instance_of(Filters::Name).to receive(:apply).and_return(
          ApplicationForm.none
        )
        expect(application_forms).to be_empty
      end

      it "filters on the assessor" do
        expect_any_instance_of(Filters::Assessor).to receive(:apply).and_return(
          ApplicationForm.none
        )
        expect(application_forms).to be_empty
      end

      it "filters on the country" do
        expect_any_instance_of(Filters::Country).to receive(:apply).and_return(
          ApplicationForm.none
        )
        expect(application_forms).to be_empty
      end
    end
  end

  describe "#assessor_filter_options" do
    subject(:assessor_filter_options) { view_object.assessor_filter_options }

    it { is_expected.to be_empty }

    context "with a staff user" do
      let(:staff) { create(:staff) }

      it { is_expected.to include(staff) }
    end
  end

  describe "#assessor_filter_checked?" do
    subject(:assessor_filter_checked?) do
      view_object.assessor_filter_checked?(option)
    end

    let(:option) { OpenStruct.new(id: 1) }

    it { is_expected.to be false }

    context "when the filter is set" do
      let(:params) { { assessor_ids: %w[1] } }

      it { is_expected.to be true }
    end
  end

  describe "#country_filter_options" do
    subject(:country_filter_options) { view_object.country_filter_options }

    it do
      is_expected.to include(
        '<option value="country:US">United States</option>'
      )
    end

    context "when the filter is set" do
      let(:params) { { location: "country:US" } }

      it do
        is_expected.to include(
          '<option selected="selected" value="country:US">United States</option>'
        )
      end
    end
  end

  describe "#name_filter_value" do
    subject(:name_filter_value) { view_object.name_filter_value }

    it { is_expected.to be_nil }

    context "when the filter is set" do
      let(:params) { { name: "abc" } }

      it { is_expected.to eq("abc") }
    end
  end
end
