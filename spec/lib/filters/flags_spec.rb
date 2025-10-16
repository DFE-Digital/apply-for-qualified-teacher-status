# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::Flags do
  subject(:filtered_scope) { described_class.apply(scope:, params:) }

  let!(:application_form_prioritised) do
    create(:application_form, :submitted).tap do |application_form|
      create(:assessment, prioritised: true, application_form:)
    end
  end

  let!(:application_form_prioritised_and_on_hold) do
    create(:application_form, :submitted).tap do |application_form|
      create(:assessment, prioritised: true, application_form:)
      create(:application_hold, application_form:)
    end
  end

  let!(:application_form_not_prioritised) do
    create(:application_form, :submitted).tap do |application_form|
      create(:assessment, prioritised: false, application_form:)
    end
  end

  let!(:application_form_not_prioritised_on_hold) do
    create(:application_form, :submitted).tap do |application_form|
      create(:assessment, prioritised: false, application_form:)
      create(:application_hold, application_form:)
    end
  end

  context "the params does not include prioritised or on_hold" do
    let(:params) { {} }
    let(:scope) { ApplicationForm.all }

    it "includes all applications" do
      expect(filtered_scope).to include(
        application_form_prioritised,
        application_form_prioritised_and_on_hold,
        application_form_not_prioritised,
        application_form_not_prioritised_on_hold,
      )
    end
  end

  context "the params does not include 'prioritised' or 'on_hold' under display" do
    let(:params) { { prioritised: nil, on_hold: nil } }
    let(:scope) { ApplicationForm.all }

    it "includes all applications" do
      expect(filtered_scope).to include(
        application_form_prioritised,
        application_form_prioritised_and_on_hold,
        application_form_not_prioritised,
        application_form_not_prioritised_on_hold,
      )
    end
  end

  context "the params does include 'prioritised' as 'true'" do
    let(:params) { { prioritised: "true" } }
    let(:scope) { ApplicationForm.all }

    it "includes all prioritised applications" do
      expect(filtered_scope).to include(
        application_form_prioritised,
        application_form_prioritised_and_on_hold,
      )

      expect(filtered_scope).not_to include(
        application_form_not_prioritised,
        application_form_not_prioritised_on_hold,
      )
    end
  end

  context "the params does include 'on_hold' as 'true'" do
    let(:params) { { on_hold: "true" } }
    let(:scope) { ApplicationForm.all }

    it "includes all on hold applications" do
      expect(filtered_scope).to include(
        application_form_prioritised_and_on_hold,
        application_form_not_prioritised_on_hold,
      )

      expect(filtered_scope).not_to include(
        application_form_prioritised,
        application_form_not_prioritised,
      )
    end
  end

  context "the params does include 'prioritised' and 'on_hold' as 'true'" do
    let(:params) { { prioritised: "true", on_hold: "true" } }
    let(:scope) { ApplicationForm.all }

    it "includes only prioritised and on hold applications" do
      expect(filtered_scope).to include(
        application_form_prioritised_and_on_hold,
      )

      expect(filtered_scope).not_to include(
        application_form_prioritised,
        application_form_not_prioritised,
        application_form_not_prioritised_on_hold,
      )
    end
  end
end
