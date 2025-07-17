# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::Prioritised do
  subject(:filtered_scope) { described_class.apply(scope:, params:) }

  let!(:application_form_prioritised) do
    create(:application_form, :submitted).tap do |application_form|
      create(:assessment, prioritised: true, application_form:)
    end
  end

  let!(:application_form_not_prioritised) do
    create(:application_form, :submitted).tap do |application_form|
      create(:assessment, prioritised: false, application_form:)
    end
  end

  context "the params does not include prioritised" do
    let(:params) { {} }
    let(:scope) { ApplicationForm.all }

    it "includes all applications" do
      expect(filtered_scope).to include(
        application_form_prioritised,
        application_form_not_prioritised,
      )
    end
  end

  context "the params does not include 'prioritised' under display" do
    let(:params) { { prioritised: nil } }
    let(:scope) { ApplicationForm.all }

    it "includes all applications" do
      expect(filtered_scope).to include(
        application_form_prioritised,
        application_form_not_prioritised,
      )
    end
  end

  context "the params does include 'prioritised' as 'true'" do
    let(:params) { { prioritised: "true" } }
    let(:scope) { ApplicationForm.all }

    it "includes all prioritised applications" do
      expect(filtered_scope).to include(application_form_prioritised)

      expect(filtered_scope).not_to include(application_form_not_prioritised)
    end
  end
end
