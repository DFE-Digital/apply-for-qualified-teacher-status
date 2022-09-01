# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ApplicationFormsShowViewObject do
  subject(:view_object) do
    described_class.new(params: ActionController::Parameters.new(params))
  end

  let(:params) { {} }

  describe "#application_form" do
    subject(:application_form) { view_object.application_form }

    it "raise an error" do
      expect { application_form }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "with an application form" do
      let(:params) { { id: create(:application_form).id } }

      it { is_expected.to_not be_nil }
    end
  end

  describe "#back_link_path" do
    subject(:back_link_path) { view_object.back_link_path }

    it { is_expected.to eq("/assessor/applications") }

    context "with search params" do
      let(:params) { { search: { states: %w[awarded] } } }

      it { is_expected.to eq("/assessor/applications?states%5B%5D=awarded") }
    end
  end
end
