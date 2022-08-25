# == Schema Information
#
# Table name: timeline_events
#
#  id                  :bigint           not null, primary key
#  annotation          :string           default(""), not null
#  creator_type        :string
#  event_type          :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
#  creator_id          :integer
#
# Indexes
#
#  index_timeline_events_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
FactoryBot.define do
  factory :timeline_event do
    association :application_form
    event_type { TimelineEvent.event_types.keys.sample }
  end
end
