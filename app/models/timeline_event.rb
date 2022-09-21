# frozen_string_literal: true

# == Schema Information
#
# Table name: timeline_events
#
#  id                  :bigint           not null, primary key
#  annotation          :string           default(""), not null
#  creator_type        :string
#  event_type          :string           not null
#  eventable_type      :string
#  new_state           :string           default(""), not null
#  old_state           :string           default(""), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
#  assignee_id         :bigint
#  creator_id          :integer
#  eventable_id        :bigint
#
# Indexes
#
#  index_timeline_events_on_application_form_id  (application_form_id)
#  index_timeline_events_on_assignee_id          (assignee_id)
#  index_timeline_events_on_eventable            (eventable_type,eventable_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#  fk_rails_...  (assignee_id => staff.id)
#
class TimelineEvent < ApplicationRecord
  belongs_to :application_form
  belongs_to :creator, polymorphic: true
  belongs_to :eventable, polymorphic: true, optional: true

  enum event_type: {
         assessor_assigned: "assessor_assigned",
         reviewer_assigned: "reviewer_assigned",
         state_changed: "state_changed",
         assessment_section_recorded: "assessment_section_recorded",
       }
  validates :event_type, inclusion: { in: event_types.values }

  belongs_to :assignee, class_name: "Staff", optional: true
  validates :assignee,
            presence: true,
            if: -> { assessor_assigned? || reviewer_assigned? }
  validates :assignee,
            absence: true,
            unless: -> { assessor_assigned? || reviewer_assigned? }

  validates :old_state, :new_state, presence: true, if: :state_changed?
  validates :old_state, :new_state, absence: true, unless: :state_changed?
end
