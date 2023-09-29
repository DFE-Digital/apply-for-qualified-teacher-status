# == Schema Information
#
# Table name: timeline_events
#
#  id                    :bigint           not null, primary key
#  age_range_max         :integer
#  age_range_min         :integer
#  age_range_note        :text             default(""), not null
#  column_name           :string           default(""), not null
#  creator_name          :string           default(""), not null
#  creator_type          :string
#  event_type            :string           not null
#  mailer_action_name    :string           default(""), not null
#  mailer_class_name     :string           default(""), not null
#  message_subject       :string           default(""), not null
#  new_value             :text             default(""), not null
#  old_value             :text             default(""), not null
#  requestable_type      :string
#  subjects              :text             default([]), not null, is an Array
#  subjects_note         :text             default(""), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  application_form_id   :bigint           not null
#  assessment_id         :bigint
#  assessment_section_id :bigint
#  assignee_id           :bigint
#  creator_id            :integer
#  note_id               :bigint
#  requestable_id        :bigint
#  work_history_id       :bigint
#
# Indexes
#
#  index_timeline_events_on_application_form_id    (application_form_id)
#  index_timeline_events_on_assessment_id          (assessment_id)
#  index_timeline_events_on_assessment_section_id  (assessment_section_id)
#  index_timeline_events_on_assignee_id            (assignee_id)
#  index_timeline_events_on_note_id                (note_id)
#  index_timeline_events_on_requestable            (requestable_type,requestable_id)
#  index_timeline_events_on_work_history_id        (work_history_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#  fk_rails_...  (assessment_id => assessments.id)
#  fk_rails_...  (assessment_section_id => assessment_sections.id)
#  fk_rails_...  (assignee_id => staff.id)
#  fk_rails_...  (note_id => notes.id)
#  fk_rails_...  (work_history_id => work_histories.id)
#
require "rails_helper"

RSpec.describe TimelineEvent do
  subject(:timeline_event) { build(:timeline_event) }

  describe "associations" do
    it { is_expected.to belong_to(:assessment_section).optional }
    it { is_expected.to belong_to(:note).optional }
    it { is_expected.to belong_to(:assessment).optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:creator) }
    it { is_expected.to validate_presence_of(:creator_name) }

    context "with a creator reference" do
      before { timeline_event.creator = create(:staff) }

      it { is_expected.to_not validate_presence_of(:creator_name) }
    end

    context "with a creator name" do
      before { timeline_event.creator_name = "DQT" }

      it { is_expected.to_not validate_presence_of(:creator) }
    end

    it do
      is_expected.to define_enum_for(:event_type).with_values(
        action_required_by_changed: "action_required_by_changed",
        age_range_subjects_verified: "age_range_subjects_verified",
        assessment_section_recorded: "assessment_section_recorded",
        assessor_assigned: "assessor_assigned",
        email_sent: "email_sent",
        information_changed: "information_changed",
        note_created: "note_created",
        requestable_assessed: "requestable_assessed",
        requestable_expired: "requestable_expired",
        requestable_received: "requestable_received",
        requestable_requested: "requestable_requested",
        reviewer_assigned: "reviewer_assigned",
        stage_changed: "stage_changed",
        status_changed: "status_changed",
      ).backed_by_column_of_type(:string)
    end

    context "with an assessor assigned event type" do
      before { timeline_event.event_type = :assessor_assigned }

      it { is_expected.to_not validate_presence_of(:assignee) }
      it { is_expected.to validate_absence_of(:assessment_section) }
      it { is_expected.to validate_absence_of(:note) }
      it { is_expected.to validate_absence_of(:mailer_class_name) }
      it { is_expected.to validate_absence_of(:mailer_action_name) }
      it { is_expected.to validate_absence_of(:message_subject) }
      it { is_expected.to validate_absence_of(:assessment) }
      it { is_expected.to validate_absence_of(:age_range_min) }
      it { is_expected.to validate_absence_of(:age_range_max) }
      it { is_expected.to validate_absence_of(:subjects) }
      it { is_expected.to validate_absence_of(:requestable_id) }
      it { is_expected.to validate_absence_of(:requestable_type) }
      it { is_expected.to validate_absence_of(:work_history_id) }
      it { is_expected.to validate_absence_of(:column_name) }
      it { is_expected.to validate_absence_of(:old_value) }
      it { is_expected.to validate_absence_of(:new_value) }
    end

    context "with an reviewer assigned event type" do
      before { timeline_event.event_type = :reviewer_assigned }

      it { is_expected.to_not validate_presence_of(:assignee) }
      it { is_expected.to validate_absence_of(:assessment_section) }
      it { is_expected.to validate_absence_of(:note) }
      it { is_expected.to validate_absence_of(:mailer_class_name) }
      it { is_expected.to validate_absence_of(:mailer_action_name) }
      it { is_expected.to validate_absence_of(:message_subject) }
      it { is_expected.to validate_absence_of(:assessment) }
      it { is_expected.to validate_absence_of(:age_range_min) }
      it { is_expected.to validate_absence_of(:age_range_max) }
      it { is_expected.to validate_absence_of(:subjects) }
      it { is_expected.to validate_absence_of(:requestable_id) }
      it { is_expected.to validate_absence_of(:requestable_type) }
      it { is_expected.to validate_absence_of(:work_history_id) }
      it { is_expected.to validate_absence_of(:column_name) }
      it { is_expected.to validate_absence_of(:old_value) }
      it { is_expected.to validate_absence_of(:new_value) }
    end

    context "with a status changed event type" do
      before { timeline_event.event_type = :status_changed }

      it { is_expected.to validate_absence_of(:assignee) }
      it { is_expected.to validate_absence_of(:assessment_section) }
      it { is_expected.to validate_absence_of(:note) }
      it { is_expected.to validate_absence_of(:mailer_class_name) }
      it { is_expected.to validate_absence_of(:mailer_action_name) }
      it { is_expected.to validate_absence_of(:message_subject) }
      it { is_expected.to validate_absence_of(:assessment) }
      it { is_expected.to validate_absence_of(:age_range_min) }
      it { is_expected.to validate_absence_of(:age_range_max) }
      it { is_expected.to validate_absence_of(:subjects) }
      it { is_expected.to validate_absence_of(:requestable_id) }
      it { is_expected.to validate_absence_of(:requestable_type) }
      it { is_expected.to validate_absence_of(:work_history_id) }
      it { is_expected.to validate_absence_of(:column_name) }
      it { is_expected.to validate_presence_of(:old_value) }
      it { is_expected.to validate_presence_of(:new_value) }
    end

    context "with an assessment section recorded event type" do
      before { timeline_event.event_type = :assessment_section_recorded }

      it { is_expected.to validate_absence_of(:assignee) }
      it { is_expected.to validate_presence_of(:assessment_section) }
      it { is_expected.to validate_absence_of(:note) }
      it { is_expected.to validate_absence_of(:mailer_class_name) }
      it { is_expected.to validate_absence_of(:mailer_action_name) }
      it { is_expected.to validate_absence_of(:message_subject) }
      it { is_expected.to validate_absence_of(:assessment) }
      it { is_expected.to validate_absence_of(:age_range_min) }
      it { is_expected.to validate_absence_of(:age_range_max) }
      it { is_expected.to validate_absence_of(:subjects) }
      it { is_expected.to validate_absence_of(:requestable_id) }
      it { is_expected.to validate_absence_of(:requestable_type) }
      it { is_expected.to validate_absence_of(:work_history_id) }
      it { is_expected.to validate_absence_of(:column_name) }
      it { is_expected.to validate_presence_of(:old_value) }
      it { is_expected.to validate_presence_of(:new_value) }
    end

    context "with a note created event type" do
      before { timeline_event.event_type = :note_created }

      it { is_expected.to validate_absence_of(:assignee) }
      it { is_expected.to validate_absence_of(:assessment_section) }
      it { is_expected.to validate_presence_of(:note) }
      it { is_expected.to validate_absence_of(:mailer_class_name) }
      it { is_expected.to validate_absence_of(:mailer_action_name) }
      it { is_expected.to validate_absence_of(:message_subject) }
      it { is_expected.to validate_absence_of(:assessment) }
      it { is_expected.to validate_absence_of(:age_range_min) }
      it { is_expected.to validate_absence_of(:age_range_max) }
      it { is_expected.to validate_absence_of(:subjects) }
      it { is_expected.to validate_absence_of(:requestable_id) }
      it { is_expected.to validate_absence_of(:requestable_type) }
      it { is_expected.to validate_absence_of(:work_history_id) }
      it { is_expected.to validate_absence_of(:column_name) }
      it { is_expected.to validate_absence_of(:old_value) }
      it { is_expected.to validate_absence_of(:new_value) }
    end

    context "with an email sent event type" do
      before { timeline_event.event_type = :email_sent }

      it { is_expected.to validate_absence_of(:assignee) }
      it { is_expected.to validate_absence_of(:assessment_section) }
      it { is_expected.to validate_absence_of(:note) }
      it { is_expected.to validate_presence_of(:mailer_class_name) }
      it { is_expected.to validate_presence_of(:mailer_action_name) }
      it { is_expected.to validate_presence_of(:message_subject) }
      it { is_expected.to validate_absence_of(:assessment) }
      it { is_expected.to validate_absence_of(:age_range_min) }
      it { is_expected.to validate_absence_of(:age_range_max) }
      it { is_expected.to validate_absence_of(:subjects) }
      it { is_expected.to validate_absence_of(:requestable_id) }
      it { is_expected.to validate_absence_of(:requestable_type) }
      it { is_expected.to validate_absence_of(:work_history_id) }
      it { is_expected.to validate_absence_of(:column_name) }
      it { is_expected.to validate_absence_of(:old_value) }
      it { is_expected.to validate_absence_of(:new_value) }
    end

    context "with an age range subjects verified event type" do
      before { timeline_event.event_type = :age_range_subjects_verified }

      it { is_expected.to validate_absence_of(:assignee) }
      it { is_expected.to validate_absence_of(:assessment_section) }
      it { is_expected.to validate_absence_of(:note) }
      it { is_expected.to validate_absence_of(:mailer_class_name) }
      it { is_expected.to validate_absence_of(:mailer_action_name) }
      it { is_expected.to validate_absence_of(:message_subject) }
      it { is_expected.to validate_presence_of(:assessment) }
      it { is_expected.to validate_presence_of(:age_range_min) }
      it { is_expected.to validate_presence_of(:age_range_max) }
      it { is_expected.to validate_presence_of(:subjects) }
      it { is_expected.to validate_absence_of(:requestable_id) }
      it { is_expected.to validate_absence_of(:requestable_type) }
      it { is_expected.to validate_absence_of(:work_history_id) }
      it { is_expected.to validate_absence_of(:column_name) }
      it { is_expected.to validate_absence_of(:old_value) }
      it { is_expected.to validate_absence_of(:new_value) }
    end

    context "with a requestable requested event type" do
      before { timeline_event.event_type = :requestable_received }

      it { is_expected.to validate_absence_of(:assignee) }
      it { is_expected.to validate_absence_of(:assessment_section) }
      it { is_expected.to validate_absence_of(:note) }
      it { is_expected.to validate_absence_of(:mailer_class_name) }
      it { is_expected.to validate_absence_of(:mailer_action_name) }
      it { is_expected.to validate_absence_of(:message_subject) }
      it { is_expected.to validate_absence_of(:assessment) }
      it { is_expected.to validate_absence_of(:age_range_min) }
      it { is_expected.to validate_absence_of(:age_range_max) }
      it { is_expected.to validate_absence_of(:subjects) }
      it { is_expected.to validate_presence_of(:requestable_id) }
      it { is_expected.to validate_presence_of(:requestable_type) }
      it do
        is_expected.to validate_inclusion_of(:requestable_type).in_array(
          %w[
            FurtherInformationRequest
            ProfessionalStandingRequest
            QualificationRequest
            ReferenceRequest
          ],
        )
      end
      it { is_expected.to validate_absence_of(:work_history_id) }
      it { is_expected.to validate_absence_of(:column_name) }
      it { is_expected.to validate_absence_of(:old_value) }
      it { is_expected.to validate_absence_of(:new_value) }
    end

    context "with a requestable received event type" do
      before { timeline_event.event_type = :requestable_received }

      it { is_expected.to validate_absence_of(:assignee) }
      it { is_expected.to validate_absence_of(:assessment_section) }
      it { is_expected.to validate_absence_of(:note) }
      it { is_expected.to validate_absence_of(:mailer_class_name) }
      it { is_expected.to validate_absence_of(:mailer_action_name) }
      it { is_expected.to validate_absence_of(:message_subject) }
      it { is_expected.to validate_absence_of(:assessment) }
      it { is_expected.to validate_absence_of(:age_range_min) }
      it { is_expected.to validate_absence_of(:age_range_max) }
      it { is_expected.to validate_absence_of(:subjects) }
      it { is_expected.to validate_presence_of(:requestable_id) }
      it { is_expected.to validate_presence_of(:requestable_type) }
      it do
        is_expected.to validate_inclusion_of(:requestable_type).in_array(
          %w[
            FurtherInformationRequest
            ProfessionalStandingRequest
            QualificationRequest
            ReferenceRequest
          ],
        )
      end
      it { is_expected.to validate_absence_of(:work_history_id) }
      it { is_expected.to validate_absence_of(:column_name) }
      it { is_expected.to validate_absence_of(:old_value) }
      it { is_expected.to validate_absence_of(:new_value) }
    end

    context "with a requestable expired event type" do
      before { timeline_event.event_type = :requestable_expired }

      it { is_expected.to validate_absence_of(:assignee) }
      it { is_expected.to validate_absence_of(:assessment_section) }
      it { is_expected.to validate_absence_of(:note) }
      it { is_expected.to validate_absence_of(:mailer_class_name) }
      it { is_expected.to validate_absence_of(:mailer_action_name) }
      it { is_expected.to validate_absence_of(:message_subject) }
      it { is_expected.to validate_absence_of(:assessment) }
      it { is_expected.to validate_absence_of(:age_range_min) }
      it { is_expected.to validate_absence_of(:age_range_max) }
      it { is_expected.to validate_absence_of(:subjects) }
      it { is_expected.to validate_presence_of(:requestable_id) }
      it { is_expected.to validate_presence_of(:requestable_type) }
      it do
        is_expected.to validate_inclusion_of(:requestable_type).in_array(
          %w[
            FurtherInformationRequest
            ProfessionalStandingRequest
            QualificationRequest
            ReferenceRequest
          ],
        )
      end
      it { is_expected.to validate_absence_of(:work_history_id) }
      it { is_expected.to validate_absence_of(:column_name) }
      it { is_expected.to validate_absence_of(:old_value) }
      it { is_expected.to validate_absence_of(:new_value) }
    end

    context "with a requestable assessed event type" do
      before { timeline_event.event_type = :requestable_assessed }

      it { is_expected.to validate_absence_of(:assignee) }
      it { is_expected.to validate_absence_of(:assessment_section) }
      it { is_expected.to validate_absence_of(:note) }
      it { is_expected.to validate_absence_of(:mailer_class_name) }
      it { is_expected.to validate_absence_of(:mailer_action_name) }
      it { is_expected.to validate_absence_of(:message_subject) }
      it { is_expected.to validate_absence_of(:assessment) }
      it { is_expected.to validate_absence_of(:age_range_min) }
      it { is_expected.to validate_absence_of(:age_range_max) }
      it { is_expected.to validate_absence_of(:subjects) }
      it { is_expected.to validate_presence_of(:requestable_id) }
      it { is_expected.to validate_presence_of(:requestable_type) }
      it do
        is_expected.to validate_inclusion_of(:requestable_type).in_array(
          %w[
            FurtherInformationRequest
            ProfessionalStandingRequest
            QualificationRequest
            ReferenceRequest
          ],
        )
      end
      it { is_expected.to validate_absence_of(:work_history_id) }
      it { is_expected.to validate_absence_of(:column_name) }
      it { is_expected.to validate_absence_of(:old_value) }
      it { is_expected.to validate_absence_of(:new_value) }
    end

    context "with an action required by changed event type" do
      before { timeline_event.event_type = :action_required_by_changed }

      it { is_expected.to validate_absence_of(:assignee) }
      it { is_expected.to validate_absence_of(:assessment_section) }
      it { is_expected.to validate_absence_of(:note) }
      it { is_expected.to validate_absence_of(:mailer_class_name) }
      it { is_expected.to validate_absence_of(:mailer_action_name) }
      it { is_expected.to validate_absence_of(:message_subject) }
      it { is_expected.to validate_absence_of(:assessment) }
      it { is_expected.to validate_absence_of(:age_range_min) }
      it { is_expected.to validate_absence_of(:age_range_max) }
      it { is_expected.to validate_absence_of(:subjects) }
      it { is_expected.to validate_absence_of(:requestable_id) }
      it { is_expected.to validate_absence_of(:requestable_type) }
      it { is_expected.to validate_absence_of(:work_history_id) }
      it { is_expected.to validate_absence_of(:column_name) }
      it { is_expected.to validate_presence_of(:old_value) }
      it { is_expected.to validate_presence_of(:new_value) }
    end

    context "with a stage changed event type" do
      before { timeline_event.event_type = :stage_changed }

      it { is_expected.to validate_absence_of(:assignee) }
      it { is_expected.to validate_absence_of(:assessment_section) }
      it { is_expected.to validate_absence_of(:note) }
      it { is_expected.to validate_absence_of(:mailer_class_name) }
      it { is_expected.to validate_absence_of(:mailer_action_name) }
      it { is_expected.to validate_absence_of(:message_subject) }
      it { is_expected.to validate_absence_of(:assessment) }
      it { is_expected.to validate_absence_of(:age_range_min) }
      it { is_expected.to validate_absence_of(:age_range_max) }
      it { is_expected.to validate_absence_of(:subjects) }
      it { is_expected.to validate_absence_of(:requestable_id) }
      it { is_expected.to validate_absence_of(:requestable_type) }
      it { is_expected.to validate_absence_of(:work_history_id) }
      it { is_expected.to validate_absence_of(:column_name) }
      it { is_expected.to validate_presence_of(:old_value) }
      it { is_expected.to validate_presence_of(:new_value) }
    end
  end
end
