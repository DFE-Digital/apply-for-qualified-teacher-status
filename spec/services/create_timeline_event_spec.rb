# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateTimelineEvent do
  let(:application_form) { create(:application_form) }

  subject(:call) do
    described_class.call(
      "status_changed",
      application_form:,
      user:,
      old_value: "submitted",
      new_value: "awarded",
    )
  end

  context "with a staff user" do
    let(:user) { create(:staff) }

    it "records a timeline event" do
      expect { call }.to have_recorded_timeline_event(
        :status_changed,
        creator: user,
        creator_name: "",
      )
    end
  end

  context "with a string user" do
    let(:user) { "Awarded" }

    it "records a timeline event" do
      expect { call }.to have_recorded_timeline_event(
        :status_changed,
        creator: nil,
        creator_name: "Awarded",
      )
    end
  end
end
