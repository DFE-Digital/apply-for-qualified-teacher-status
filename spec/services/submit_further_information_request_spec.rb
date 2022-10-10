# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubmitFurtherInformationRequest do
  let(:application_form) { create(:application_form, :submitted) }
  let(:further_information_request) do
    create(
      :further_information_request,
      :requested,
      assessment: create(:assessment, application_form:),
    )
  end
  let(:user) { application_form.teacher }

  subject(:call) { described_class.call(further_information_request:, user:) }

  context "with an already received further information request" do
    before { further_information_request.received! }

    it "raises an error" do
      expect { call }.to raise_error(
        SubmitFurtherInformationRequest::AlreadySubmitted,
      )
    end
  end

  it "changes the further information request state to received" do
    expect { call }.to change(further_information_request, :received?).from(
      false,
    ).to(true)
  end

  it "changes the application form state to further information received" do
    expect { call }.to change(
      application_form,
      :further_information_received?,
    ).from(false).to(true)
  end

  describe "recording timeline event" do
    subject(:timeline_event) do
      TimelineEvent.state_changed.where(application_form:).last
    end

    context "after calling the service" do
      before { call }

      it { is_expected.to_not be_nil }

      it "sets the attributes correctly" do
        expect(timeline_event.creator).to eq(user)
        expect(timeline_event.old_state).to eq("submitted")
        expect(timeline_event.new_state).to eq("further_information_received")
      end
    end
  end
end
