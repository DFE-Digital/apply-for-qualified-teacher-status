# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::DraftApplicationFormsFilterForm do
  subject(:form) { described_class.new(email:) }

  let(:email) { "draft-applicant@example.com" }

  it "retains the search value" do
    expect(form.email).to eq(email)
  end

  it "does not require a complete email address" do
    form.email = "draft-applicant"
    expect(form).to be_valid
  end

  context "without a search value" do
    let(:email) { nil }

    it { is_expected.to be_valid }
  end
end
