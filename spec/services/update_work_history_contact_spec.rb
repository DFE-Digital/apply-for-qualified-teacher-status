# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateWorkHistoryContact do
  let(:work_history) { create(:work_history, :completed) }
  let(:user) { create(:staff, :confirmed) }
  let(:new_name) { "New name" }
  let(:new_job) { "New job" }
  let(:new_email) { "new@example.com" }

  subject(:call) do
    described_class.call(
      work_history:,
      user:,
      name: new_name,
      job: new_job,
      email: new_email,
    )
  end

  it "changes the contact name" do
    expect { call }.to change(work_history, :contact_name).to(new_name)
  end

  it "changes the contact job" do
    expect { call }.to change(work_history, :contact_job).to(new_job)
  end

  it "changes the contact email" do
    expect { call }.to change(work_history, :contact_email).to(new_email)
  end

  it "changes the canonical contact email" do
    expect { call }.to change(work_history, :canonical_contact_email).to(
      new_email,
    )
  end

  it "doesn't send any emails" do
    expect { call }.to_not have_enqueued_mail(
      RefereeMailer,
      :reference_requested,
    )
  end

  it "records timeline events" do
    expect { call }.to have_recorded_timeline_event(
      :information_changed,
      creator: user,
      work_history:,
    )
  end

  describe "when references already sent out" do
    before { create(:reference_request, work_history:) }

    it "sends an email to the referee" do
      expect { call }.to have_enqueued_mail(RefereeMailer, :reference_requested)
    end

    it "sends an email to the teacher" do
      expect { call }.to have_enqueued_mail(
        TeacherMailer,
        :references_requested,
      )
    end
  end
end
