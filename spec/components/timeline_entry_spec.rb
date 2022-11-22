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
    let(:timeline_event) do
      create(
        :timeline_event,
        :state_changed,
        old_state: "submitted",
        new_state: "awarded",
      )
    end
    let(:old_state) do
      I18n.t("application_form.status.#{timeline_event.old_state}.assessor")
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
    let(:assessment_section) do
      create(
        :assessment_section,
        :personal_information,
        :failed,
        selected_failure_reasons: {
          identification_document_expired: "A note.",
        },
      )
    end
    let(:timeline_event) do
      create(
        :timeline_event,
        :assessment_section_recorded,
        new_state: "completed",
        assessment_section:,
      )
    end

    it "describes the event" do
      expect(component.text).to include("Personal Information:")
      expect(component.text).to include("Completed")
      expect(component.text).to include("The ID document has expired.")
      expect(component.text).to include("A note.")
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
    let(:further_information_request) do
      create(
        :further_information_request,
        failure_assessor_note: "For this reason.",
      )
    end
    let(:timeline_event) do
      create(
        :timeline_event,
        :further_information_request_assessed,
        further_information_request:,
      )
    end

    it "describes the event" do
      expect(component.text).to include(
        "Further information request has been assessed.",
      )
      expect(component.text).to include("For this reason.")
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "email sent" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :email_sent,
        mailer_action_name: "application_received",
      )
    end

    it "describes the event" do
      expect(component.text).to include(
        "We’ve received your application for qualified teacher status (QTS)",
      )
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "age range subjects verified" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :age_range_subjects_verified,
        assessment:
          create(
            :assessment,
            age_range_min: 7,
            age_range_max: 11,
            age_range_note: "Age range note.",
            subjects: %w[ancient_hebrew],
            subjects_note: "Subjects note.",
          ),
      )
    end

    it "describes the event" do
      expect(component.text).to include("Age range: 7 to 11")
      expect(component.text).to include("Age range note.")
      expect(component.text).to include("Subjects: Ancient Hebrew")
      expect(component.text).to include("Subjects note.")
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end
end
