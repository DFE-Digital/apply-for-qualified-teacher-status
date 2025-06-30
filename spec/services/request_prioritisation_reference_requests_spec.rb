# frozen_string_literal: true

require "rails_helper"

RSpec.describe RequestPrioritisationReferenceRequests do
  subject(:call) { described_class.call(assessment:, user:) }

  let(:application_form) { create(:submitted_application_form) }
  let(:user) { "John Smith" }
  let(:assessment) { create(:assessment, application_form:) }

  let(:work_history_in_england_one) do
    create :work_history, :current_role_in_england
  end
  let(:work_history_in_england_two) do
    create :work_history, :current_role_in_england
  end
  let(:work_history_in_england_three) do
    create :work_history, :current_role_in_england
  end

  before do
    create :prioritisation_work_history_check,
           work_history: work_history_in_england_one,
           assessment:,
           passed: true
    create :prioritisation_work_history_check,
           work_history: work_history_in_england_two,
           assessment:,
           passed: true
    create :prioritisation_work_history_check,
           work_history: work_history_in_england_three,
           assessment:,
           passed: false
    allow(RequestRequestable).to receive(:call)
    allow(ApplicationFormStatusUpdater).to receive(:call)
  end

  it "changes generates reference requests for all prioritisation work history checks that have passed" do
    expect { call }.to change(
      assessment.prioritisation_reference_requests,
      :count,
    ).by(2)

    expect(
      assessment.prioritisation_reference_requests.pluck(:work_history_id),
    ).to contain_exactly(
      work_history_in_england_one.id,
      work_history_in_england_two.id,
    )
  end

  it "calls RequestRequestable for all passed prioritisation requests generated" do
    call

    assessment.reload.prioritisation_reference_requests.each do |requestable|
      expect(RequestRequestable).to have_received(:call).with(
        requestable:,
        user:,
      )
    end
  end

  it "calls ApplicationFormStatusUpdater" do
    call

    expect(ApplicationFormStatusUpdater).to have_received(:call).with(
      application_form:,
      user:,
    )
  end

  context "with an already requested prioritisation reference request" do
    before { create(:requested_prioritisation_reference_request, assessment:) }

    it "raises an error" do
      expect { call }.to raise_error(
        RequestPrioritisationReferenceRequests::AlreadyRequested,
      )
    end
  end
end
