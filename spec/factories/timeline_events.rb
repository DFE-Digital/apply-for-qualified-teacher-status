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
FactoryBot.define do
  factory :timeline_event do
    association :application_form

    association :creator, factory: :staff

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

    trait :assessment_section_recorded do
      event_type { "assessment_section_recorded" }
      assessment_section do
        build(
          :assessment_section,
          :passed,
          :personal_information,
          assessment: build(:assessment, application_form:),
        )
      end
    end

    trait :note_created do
      event_type { "note_created" }
      association :note
    end

    trait :further_information_request_assessed do
      event_type { "further_information_request_assessed" }
      association :further_information_request
    end
  end
end
