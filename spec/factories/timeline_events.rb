# == Schema Information
#
# Table name: timeline_events
#
#  id                  :bigint           not null, primary key
#  annotation          :string           default(""), not null
#  creator_type        :string
#  event_type          :string           not null
#  new_state           :string           default(""), not null
#  old_state           :string           default(""), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
#  assignee_id         :bigint
#  creator_id          :integer
#
# Indexes
#
#  index_timeline_events_on_application_form_id  (application_form_id)
#  index_timeline_events_on_assignee_id          (assignee_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#  fk_rails_...  (assignee_id => staff.id)
#
FactoryBot.define do
  factory :timeline_event do
    association :application_form

    trait :assessor_assigned do
      event_type { "assessor_assigned" }
      association :assignee, factory: :staff
    end

    trait :reviewer_assigned do
      event_type { "reviewer_assigned" }
      association :assignee, factory: :staff
    end

    trait :state_changed do
      event_type { "state_changed" }
      old_state { ApplicationForm.states.keys.sample }
      new_state { ApplicationForm.states.keys.sample }
    end
  end
end
