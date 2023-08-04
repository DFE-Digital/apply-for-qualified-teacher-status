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
      I18n.t("components.status_tag.#{timeline_event.old_state}")
    end
    let(:new_state) do
      I18n.t("components.status_tag.#{timeline_event.new_state}")
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
      create(:assessment_section, :personal_information, :failed)
    end

    let(:timeline_event) do
      create(
        :timeline_event,
        :assessment_section_recorded,
        new_state: "completed",
        assessment_section:,
      )
    end

    let(:failure_reason) { assessment_section.selected_failure_reasons.first }
    let(:expected_failure_reason_text) do
      I18n.t(
        failure_reason.key,
        scope: %i[
          assessor_interface
          assessment_sections
          failure_reasons
          as_statement
        ],
      )
    end

    it "describes the event" do
      expect(component.text).to include("Personal Information:")
      expect(component.text).to include("Rejected")
      expect(component.text).to include(expected_failure_reason_text)
      expect(component.text).to include(failure_reason.assessor_feedback)
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

  context "email sent" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :email_sent,
        message_subject: "Application received",
      )
    end

    it "describes the event" do
      expect(component.text).to include("Application received")
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
        assessment: create(:assessment),
        age_range_min: 7,
        age_range_max: 11,
        age_range_note: "Age range note.",
        subjects: %w[ancient_hebrew],
        subjects_note: "Subjects note.",
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

  context "further information request requested" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :requestable_requested,
        requestable: create(:further_information_request),
      )
    end

    it "describes the event" do
      expect(component.text).to include(
        "Further information has been requested.",
      )
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "professional standing request requested" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :requestable_requested,
        requestable: create(:professional_standing_request),
      )
    end

    it "describes the event" do
      expect(component.text).to include(
        "The professional standing has been requested.",
      )
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "qualification request requested" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :requestable_requested,
        requestable: create(:qualification_request),
      )
    end

    it "describes the event" do
      expect(component.text).to include("A qualification has been requested.")
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "reference request requested" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :requestable_requested,
        requestable: create(:reference_request),
      )
    end

    it "describes the event" do
      expect(component.text).to include("A reference has been requested.")
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "further information request received" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :requestable_received,
        requestable: create(:further_information_request),
      )
    end

    it "describes the event" do
      expect(component.text).to include(
        "Further information requested on " \
          "#{timeline_event.requestable.created_at.strftime("%e %B %Y at %l:%M %P")} has been received.",
      )
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "professional standing request received" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :requestable_received,
        requestable:
          create(
            :professional_standing_request,
            location_note: "This is a note.",
          ),
      )
    end

    it "describes the event" do
      expect(component.text).to include(
        "The professional standing has been received:",
      )
      expect(component.text).to include("This is a note.")
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "qualification request received" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :requestable_received,
        requestable: create(:qualification_request),
      )
    end

    it "describes the event" do
      expect(component.text).to include("A qualification has been received.")
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "reference request received" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :requestable_received,
        requestable: create(:reference_request),
      )
    end

    it "describes the event" do
      expect(component.text).to include("A reference has been received.")
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "further information request expired" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :requestable_expired,
        requestable: create(:further_information_request),
      )
    end

    it "describes the event" do
      expect(component.text).to include(
        "Further information requested on " \
          "#{timeline_event.requestable.created_at.strftime("%e %B %Y at %l:%M %P")} has expired. " \
          "Application has been declined.",
      )
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "professional standing request expired" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :requestable_expired,
        requestable: create(:professional_standing_request),
      )
    end

    it "describes the event" do
      expect(component.text).to include(
        "The professional standing request has expired.",
      )
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "qualification request expired" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :requestable_expired,
        requestable: create(:qualification_request),
      )
    end

    it "describes the event" do
      expect(component.text).to include("A qualification request has expired.")
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "reference request expired" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :requestable_expired,
        requestable: create(:reference_request),
      )
    end

    it "describes the event" do
      expect(component.text).to include("A reference has expired.")
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
        :requestable_assessed,
        requestable: further_information_request,
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

  context "professional standing request assessed" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :requestable_assessed,
        requestable: create(:professional_standing_request),
      )
    end

    it "describes the event" do
      expect(component.text).to include(
        "The professional standing request has been assessed.",
      )
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "qualification request assessed" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :requestable_assessed,
        requestable: create(:qualification_request),
      )
    end

    it "describes the event" do
      expect(component.text).to include("A qualification has been assessed.")
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "reference request assessed" do
    let(:timeline_event) do
      create(
        :timeline_event,
        :requestable_assessed,
        requestable: create(:reference_request),
      )
    end

    it "describes the event" do
      expect(component.text).to include("A reference has been assessed.")
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end

  context "information changed" do
    let(:timeline_event) { create(:timeline_event, :information_changed) }
    let(:old_value) { timeline_event.old_value }
    let(:new_value) { timeline_event.new_value }

    it "describes the event" do
      expect(component.text.squish).to include(
        "Reference email address has changed from #{old_value} to #{new_value}.",
      )
    end

    it "attributes to the creator" do
      expect(component.text).to include(creator.name)
    end
  end
end
