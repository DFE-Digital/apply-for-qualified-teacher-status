# frozen_string_literal: true

require "rails_helper"

RSpec.describe RequestConsent do
  subject(:call) { described_class.call(assessment:, user:) }

  let(:application_form) { create(:application_form, :submitted) }
  let(:assessment) { create(:assessment, application_form:) }
  let(:user) { create(:staff) }

  before { create(:consent_request, assessment:) }

  it "changes the application form statuses" do
    expect { call }.to change(application_form, :statuses).to(
      %w[waiting_on_consent],
    )
  end

  it "queues an email job" do
    expect { call }.to have_enqueued_mail(TeacherMailer, :consent_requested)
  end

  it "records a requestable requested timeline event" do
    expect { call }.to have_recorded_timeline_event(:requestable_requested)
  end

  context "with an existing request" do
    before { create(:requested_consent_request, assessment:) }

    it "raises an error" do
      expect { call }.to raise_error(RequestConsent::AlreadyRequested)
    end
  end
end
