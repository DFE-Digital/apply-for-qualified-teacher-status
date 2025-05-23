# frozen_string_literal: true

require "rails_helper"

RSpec.describe FurtherInformationRequests::CreateFromAssessmentSections do
  subject(:call) { described_class.call(assessment:, user:) }

  let(:application_form) { create(:application_form, :submitted) }
  let(:assessment) { create(:assessment, application_form:) }
  let(:user) { create(:staff) }

  describe "creating further information request" do
    subject(:further_information_request) do
      FurtherInformationRequest.find_by(assessment:)
    end

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.not_to be_nil }

      it "sets the attributes correctly" do
        expect(further_information_request.requested?).to be true
      end
    end
  end

  it "changes the application form statuses" do
    expect { call }.to change(application_form, :statuses).to(
      %w[waiting_on_further_information],
    )
  end

  describe "sending application received email" do
    it "queues an email job" do
      expect { call }.to have_enqueued_mail(
        TeacherMailer,
        :further_information_requested,
      )
    end
  end

  it "sets the assessment recommendation" do
    expect { call }.to change(assessment, :request_further_information?).from(
      false,
    ).to(true)
  end

  it "records a requestable requested timeline event" do
    expect { call }.to have_recorded_timeline_event(:requestable_requested)
  end

  context "with an existing request" do
    before { create(:further_information_request, assessment:) }

    it "raises an error" do
      expect { call }.to raise_error(
        FurtherInformationRequests::CreateFromAssessmentSections::AlreadyExists,
      )
    end
  end
end
