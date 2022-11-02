# frozen_string_literal: true

require "rails_helper"

RSpec.describe TimelineEntry::Component, type: :component do
  subject(:component) { render_inline(described_class.new(timeline_event:)) }
  let(:creator) { timeline_event.creator }

  context "with a creator name" do
    let(:timeline_event) do
      create(:timeline_event, :state_changed, creator_name: "DQT", creator: nil)
    end

    it "describes the event" do
      expect(component.text).to include("by DQT")
    end
  end

  context "assessor assigned" do
    let(:timeline_event) { create(:timeline_event, :assessor_assigned) }
    let(:assignee) { timeline_event.assignee }

    it "describes the event" do
      expect(component.text).to include(
        "#{assignee.name} is assigned as the assessor",
      )
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "reviewer assigned" do
    let(:timeline_event) { create(:timeline_event, :reviewer_assigned) }
    let(:assignee) { timeline_event.assignee }

    it "describes the event" do
      expect(component.text).to include(
        "#{assignee.name} is assigned as the reviewer",
      )
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "state changed" do
    let(:timeline_event) { create(:timeline_event, :state_changed) }
    let(:old_state) do
      I18n.t("application_form.status.#{timeline_event.old_state}")
    end
    let(:new_state) do
      I18n.t("application_form.status.#{timeline_event.new_state}")
    end

    it "describes the event" do
      expect(component.text.squish).to include(
        "Status changed from #{old_state} to #{new_state}",
      )
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "assessment section recorded" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :assessment_section_recorded,
        new_state: "completed",
      )
    end

    it "describes the event" do
      expect(component.text).to include("Personal Information: Completed")
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "note created" do
    let(:timeline_event) { create(:timeline_event, :note_created) }
    let(:text) { timeline_event.note.text }

    it "describes the event" do
      expect(component.text).to include(text)
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "further information request assessed" do
    let(:timeline_event) do
      create(:timeline_event, :further_information_request_assessed)
    end

    it "describes the event" do
      expect(component.text).to include(
        "Further information request has been assessed.",
      )
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end
end
