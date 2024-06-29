# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReviewAssessment do
  subject(:call) { described_class.call(assessment:, user:) }

  let(:application_form) { create(:application_form, :submitted) }
  let(:assessment) { create(:assessment, application_form:) }
  let(:user) { create(:staff) }

  context "when already verified" do
    let(:assessment) { create(:assessment, :review, application_form:) }

    it "raises an error" do
      expect { call }.to raise_error(ReviewAssessment::AlreadyReviewed)
    end
  end

  it "changes the assessment recommendation" do
    expect { call }.to change(assessment, :recommendation).to("review")
  end

  it "changes the application form stage" do
    expect { call }.to change(application_form, :stage).to("review")
  end
end
