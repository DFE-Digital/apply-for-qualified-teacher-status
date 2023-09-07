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
#  new_state             :string           default(""), not null
#  new_value             :text             default(""), not null
#  old_state             :string           default(""), not null
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
      old_state { ApplicationForm.statuses.keys.sample }
      new_state { ApplicationForm.statuses.keys.sample }
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
      old_state { %i[not_started invalid completed].sample }
      new_state { %i[not_started invalid completed].sample }
    end

    trait :note_created do
      event_type { "note_created" }
      association :note
    end

    trait :email_sent do
      event_type { "email_sent" }
      mailer_class_name { "TeacherMailer" }
      mailer_action_name { "application_received" }
      message_subject { "Application received" }
    end

    trait :information_changed do
      event_type { "information_changed" }
      association :work_history
      column_name { "contact_email" }
      old_value { Faker::Internet.email }
      new_value { Faker::Internet.email }
    end

    trait :action_required_by_changed do
      event_type { "action_required_by_changed" }
      old_value { %w[admin assessor external none].sample }
      new_value { %w[admin assessor external none].sample }
    end
  end
end
