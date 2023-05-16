# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeclineQTS do
  let(:teacher) { create(:teacher) }
  let(:user) { create(:staff, :confirmed) }

  subject(:call) { described_class.call(application_form:, user:) }

  context "with an application form" do
    let(:application_form) { create(:application_form, :submitted, teacher:) }

    it "sends an email" do
      expect { call }.to have_enqueued_mail(
        TeacherMailer,
        :application_declined,
      ).with(params: { teacher: }, args: [])
    end

    it "changes the status" do
      expect { call }.to change(application_form, :status).to("declined")
    end

    it "sets the declined at date" do
      freeze_time do
        expect { call }.to change(application_form, :declined_at).to(
          Time.zone.now,
        )
      end
    end
  end

  context "with a declined application form" do
    let(:application_form) { create(:application_form, :declined, teacher:) }

    it "doesn't send an email" do
      expect { call }.to_not have_enqueued_mail(
        TeacherMailer,
        :application_declined,
      )
    end

    it "doesn't change the status" do
      expect { call }.to_not change(application_form, :status)
    end

    it "doesn't change the declined at date" do
      expect { call }.to_not change(application_form, :declined_at)
    end
  end

  context "with a quick decline decision" do
    let!(:application_form) do
      create(
        :application_form,
        :submitted,
        requires_preliminary_check: true,
        teacher:,
        assessment: create(:assessment, preliminary_check_complete: false),
      )
    end

    it "creates a quick decline timeline event" do
      expect { call }.to change(TimelineEvent, :count).by(2)
      expect(TimelineEvent.last.event_type).to eq("quick_decline")
    end
  end
end
