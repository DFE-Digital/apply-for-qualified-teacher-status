# frozen_string_literal: true

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
#  note_text             :text             default(""), not null
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
class TimelineEvent < ApplicationRecord
  belongs_to :application_form
  belongs_to :assessment, optional: true
  belongs_to :assessment_section, optional: true
  belongs_to :assignee, class_name: "Staff", optional: true
  belongs_to :creator, polymorphic: true, optional: true
  belongs_to :note, optional: true
  belongs_to :requestable, polymorphic: true, optional: true
  belongs_to :work_history, optional: true

  enum event_type: {
         action_required_by_changed: "action_required_by_changed",
         age_range_subjects_verified: "age_range_subjects_verified",
         assessment_section_recorded: "assessment_section_recorded",
         assessor_assigned: "assessor_assigned",
         email_sent: "email_sent",
         information_changed: "information_changed",
         note_created: "note_created",
         requestable_expired: "requestable_expired",
         requestable_received: "requestable_received",
         requestable_requested: "requestable_requested",
         requestable_reviewed: "requestable_reviewed",
         requestable_verified: "requestable_verified",
         reviewer_assigned: "reviewer_assigned",
         stage_changed: "stage_changed",
         status_changed: "status_changed",
       }

  validates :creator, presence: true, unless: -> { creator_name.present? }
  validates :creator_name,
            presence: true,
            unless: -> { creator_id.present? && creator_type.present? }

  validates :event_type, inclusion: { in: event_types.values }

  validates :assignee,
            absence: true,
            unless: -> { assessor_assigned? || reviewer_assigned? }

  validates :assessment_section,
            presence: true,
            if: :assessment_section_recorded?
  validates :assessment_section,
            absence: true,
            unless: :assessment_section_recorded?

  validates :note, presence: true, if: :note_created?
  validates :note, absence: true, unless: :note_created?

  validates :mailer_class_name,
            :mailer_action_name,
            :message_subject,
            presence: true,
            if: :email_sent?
  validates :mailer_class_name,
            :mailer_action_name,
            :message_subject,
            absence: true,
            unless: :email_sent?

  validates :assessment,
            :age_range_min,
            :age_range_max,
            :subjects,
            presence: true,
            if: :age_range_subjects_verified?
  validates :assessment,
            :age_range_min,
            :age_range_max,
            :age_range_note,
            :subjects,
            :subjects_note,
            absence: true,
            unless: :age_range_subjects_verified?

  validates :requestable_id, presence: true, if: :requestable_event_type?
  validates :requestable_type,
            presence: true,
            inclusion: %w[
              FurtherInformationRequest
              ProfessionalStandingRequest
              QualificationRequest
              ReferenceRequest
            ],
            if: :requestable_event_type?
  validates :requestable_id,
            :requestable_type,
            absence: true,
            unless: :requestable_event_type?

  validates :old_value,
            :new_value,
            presence: true,
            if: -> do
              action_required_by_changed? || assessment_section_recorded? ||
                information_changed? || requestable_reviewed? ||
                requestable_verified? || stage_changed? || status_changed?
            end
  validates :old_value,
            :new_value,
            absence: true,
            unless: -> do
              action_required_by_changed? || assessment_section_recorded? ||
                information_changed? || requestable_reviewed? ||
                requestable_verified? || stage_changed? || status_changed?
            end

  validates :note_text,
            absence: true,
            unless: -> { requestable_reviewed? || requestable_verified? }

  validates :column_name, presence: true, if: :information_changed?
  validates :work_history_id,
            :column_name,
            absence: true,
            unless: :information_changed?

  def requestable_event_type?
    requestable_expired? || requestable_received? || requestable_requested? ||
      requestable_reviewed? || requestable_verified?
  end
end
