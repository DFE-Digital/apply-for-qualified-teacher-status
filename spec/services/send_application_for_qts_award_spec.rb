# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendApplicationForQTSAward do
  subject(:call) { described_class.call(assessment:, user:) }

  let(:application_form) { create(:application_form, :submitted) }
  let(:assessment) { create(:assessment, application_form:) }
  let(:user) { create(:staff) }

  it "awards the assessment" do
    expect { call }.to change { assessment.reload.recommendation }.to("award")
  end

  it "assigns the verifier" do
    expect { call }.to change { application_form.reload.verifier }.to(user)
  end

  it "creates a TRSTRNRequest" do
    expect { call }.to change(TRSTRNRequest, :count).by(1)
  end

  context "when a later step fails" do
    before do
      allow(CreateTRSTRNRequest).to receive(:call).and_raise(StandardError)
    end

    it "rolls back the award" do
      initial_recommendation = assessment.recommendation
      expect { call }.to raise_error(StandardError)
      expect(assessment.reload.recommendation).to eq(initial_recommendation)
    end
  end
end
