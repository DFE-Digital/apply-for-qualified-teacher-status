# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateQuickDeclineTimelineEvent do
  let(:teacher) { create(:teacher) }
  let(:user) { create(:staff, :confirmed) }

  subject(:call) { described_class.call(application_form:, user:) }

  context "with an application form which requires a preliminary check" do
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
      expect { call }.to change(TimelineEvent, :count).by(1)
      expect(TimelineEvent.last.event_type).to eq("quick_decline")
    end
  end

  context "with an application form which doesn't require a preliminary check" do
    let!(:application_form) { create(:application_form, :submitted, teacher:) }

    it "doesn't create a quick decline timeline event" do
      expect { call }.not_to change(TimelineEvent, :count)
    end
  end
end
