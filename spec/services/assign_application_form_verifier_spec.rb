# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignApplicationFormVerifier do
  subject(:call) { described_class.call(application_form:, verifier:) }

  let!(:application_form) { create(:application_form, :submitted) }
  let(:verifier) { create(:staff) }

  it "creates a timeline event" do
    expect { call }.to change {
      application_form.timeline_events.verification_decision_made.count
    }.by(1)
  end

  describe "application form verifier" do
    subject(:verifier_on_form) { application_form.verifier }

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to be(verifier) }
    end
  end
end
