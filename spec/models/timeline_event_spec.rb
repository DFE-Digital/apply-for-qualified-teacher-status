# == Schema Information
#
# Table name: timeline_events
#
#  id                             :bigint           not null, primary key
#  annotation                     :string           default(""), not null
#  creator_type                   :string
#  event_type                     :string           not null
#  new_state                      :string           default(""), not null
#  old_state                      :string           default(""), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  application_form_id            :bigint           not null
#  assessment_section_id          :bigint
#  assignee_id                    :bigint
#  creator_id                     :integer
#  further_information_request_id :bigint
#  note_id                        :bigint
#
# Indexes
#
#  index_timeline_events_on_application_form_id             (application_form_id)
#  index_timeline_events_on_assessment_section_id           (assessment_section_id)
#  index_timeline_events_on_assignee_id                     (assignee_id)
#  index_timeline_events_on_further_information_request_id  (further_information_request_id)
#  index_timeline_events_on_note_id                         (note_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#  fk_rails_...  (assessment_section_id => assessment_sections.id)
#  fk_rails_...  (assignee_id => staff.id)
#  fk_rails_...  (further_information_request_id => further_information_requests.id)
#  fk_rails_...  (note_id => notes.id)
#
require "rails_helper"

RSpec.describe TimelineEvent do
  subject(:timeline_event) { build(:timeline_event) }

  describe "associations" do
    it { is_expected.to belong_to(:assessment_section).optional }
    it { is_expected.to belong_to(:note).optional }
    it { is_expected.to belong_to(:further_information_request).optional }
  end

  describe "validations" do
    it do
      is_expected.to define_enum_for(:event_type).with_values(
        assessor_assigned: "assessor_assigned",
        reviewer_assigned: "reviewer_assigned",
        state_changed: "state_changed",
        assessment_section_recorded: "assessment_section_recorded",
        note_created: "note_created",
        further_information_request_assessed:
          "further_information_request_assessed",
      ).backed_by_column_of_type(:string)
    end

    context "with an assessor assigned event type" do
      before { timeline_event.event_type = :assessor_assigned }

      it { is_expected.to validate_presence_of(:assignee) }
      it { is_expected.to validate_absence_of(:old_state) }
      it { is_expected.to validate_absence_of(:new_state) }
      it { is_expected.to validate_absence_of(:assessment_section) }
      it { is_expected.to validate_absence_of(:note) }
      it { is_expected.to validate_absence_of(:further_information_request) }
    end

    context "with an reviewer assigned event type" do
      before { timeline_event.event_type = :reviewer_assigned }

      it { is_expected.to validate_presence_of(:assignee) }
      it { is_expected.to validate_absence_of(:old_state) }
      it { is_expected.to validate_absence_of(:new_state) }
      it { is_expected.to validate_absence_of(:assessment_section) }
      it { is_expected.to validate_absence_of(:note) }
      it { is_expected.to validate_absence_of(:further_information_request) }
    end

    context "with a state changed event type" do
      before { timeline_event.event_type = :state_changed }

      it { is_expected.to validate_absence_of(:assignee) }
      it { is_expected.to validate_presence_of(:old_state) }
      it { is_expected.to validate_presence_of(:new_state) }
      it { is_expected.to validate_absence_of(:assessment_section) }
      it { is_expected.to validate_absence_of(:note) }
      it { is_expected.to validate_absence_of(:further_information_request) }
    end

    context "with an assessment section recorded event type" do
      before { timeline_event.event_type = :assessment_section_recorded }

      it { is_expected.to validate_absence_of(:assignee) }
      it { is_expected.to validate_absence_of(:old_state) }
      it { is_expected.to validate_absence_of(:new_state) }
      it { is_expected.to validate_presence_of(:assessment_section) }
      it { is_expected.to validate_absence_of(:note) }
      it { is_expected.to validate_absence_of(:further_information_request) }
    end

    context "with a note created event type" do
      before { timeline_event.event_type = :note_created }

      it { is_expected.to validate_absence_of(:assignee) }
      it { is_expected.to validate_absence_of(:old_state) }
      it { is_expected.to validate_absence_of(:new_state) }
      it { is_expected.to validate_absence_of(:assessment_section) }
      it { is_expected.to validate_presence_of(:note) }
      it { is_expected.to validate_absence_of(:further_information_request) }
    end

    context "with a further information request assessed event type" do
      before do
        timeline_event.event_type = :further_information_request_assessed
      end

      it { is_expected.to validate_absence_of(:assignee) }
      it { is_expected.to validate_absence_of(:old_state) }
      it { is_expected.to validate_absence_of(:new_state) }
      it { is_expected.to validate_absence_of(:assessment_section) }
      it { is_expected.to validate_absence_of(:note) }
      it { is_expected.to validate_presence_of(:further_information_request) }
    end
  end
end
