# frozen_string_literal: true

# == Schema Information
#
# Table name: timeline_events
#
#  id                  :bigint           not null, primary key
#  annotation          :string
#  event_type          :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint
#  staff_id            :integer
#
# Indexes
#
#  index_timeline_events_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
class TimelineEvent < ApplicationRecord
  belongs_to :application_form

  STATE_CHANGED = "state_changed"
end
