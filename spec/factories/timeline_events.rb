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
#  qualification_id      :bigint
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
#  index_timeline_events_on_qualification_id       (qualification_id)
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
#  fk_rails_...  (qualification_id => qualifications.id)
#  fk_rails_...  (work_history_id => work_histories.id)
#
FactoryBot.define do
  factory :timeline_event do
    application_form

    association :creator, factory: :staff

    trait :action_required_by_changed do
      event_type { "action_required_by_changed" }
      old_value { %w[admin assessor external none].sample }
      new_value { %w[admin assessor external none].sample }
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
      old_value { %i[not_started invalid completed].sample }
      new_value { %i[not_started invalid completed].sample }
    end

    trait :assessor_assigned do
      event_type { "assessor_assigned" }
      association :assignee, factory: :staff
    end

    trait :email_sent do
      event_type { "email_sent" }
      mailer_class_name { "TeacherMailer" }
      mailer_action_name { "application_received" }
      message_subject { "Application received" }
    end

    trait :information_changed do
      event_type { "information_changed" }
      work_history
      column_name { "contact_email" }
      old_value { Faker::Internet.email }
      new_value { Faker::Internet.email }
    end

    trait :note_created do
      event_type { "note_created" }
      note
    end

    trait :requestable_reviewed do
      event_type { "requestable_reviewed" }
      old_value { "not_started" }
      new_value { %w[accepted rejected].sample }
    end

    trait :requestable_verified do
      event_type { "requestable_verified" }
      old_value { "not_started" }
      new_value { %w[accepted rejected].sample }
    end

    trait :reviewer_assigned do
      event_type { "reviewer_assigned" }
      association :assignee, factory: :staff
    end

    trait :stage_changed do
      event_type { "stage_changed" }
      old_value { ApplicationForm.stages.values.sample }
      new_value { ApplicationForm.stages.values.sample }
    end

    trait :status_changed do
      event_type { "status_changed" }
      old_value { ApplicationForm.statuses.keys.sample }
      new_value { ApplicationForm.statuses.keys.sample }
    end
  end
end
