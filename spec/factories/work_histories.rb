# == Schema Information
#
# Table name: work_histories
#
#  id                      :bigint           not null, primary key
#  canonical_contact_email :text             default(""), not null
#  city                    :text             default(""), not null
#  contact_email           :text             default(""), not null
#  contact_job             :string           default(""), not null
#  contact_name            :text             default(""), not null
#  country_code            :text             default(""), not null
#  end_date                :date
#  end_date_is_estimate    :boolean          default(FALSE), not null
#  hours_per_week          :integer
#  job                     :text             default(""), not null
#  school_name             :text             default(""), not null
#  start_date              :date
#  start_date_is_estimate  :boolean          default(FALSE), not null
#  still_employed          :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  application_form_id     :bigint           not null
#
# Indexes
#
#  index_work_histories_on_application_form_id      (application_form_id)
#  index_work_histories_on_canonical_contact_email  (canonical_contact_email)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
FactoryBot.define do
  factory :work_history do
    association :application_form

    canonical_contact_email { EmailAddress.canonical(contact_email) }

    trait :completed do
      school_name { "School" }
      city { "City" }
      sequence :country_code, Country::CODES.cycle
      job { "Job" }
      hours_per_week { 30 }
      start_date { Date.new(2020, 1, 1) }
      still_employed { true }
      contact_name { Faker::Name.name }
      contact_job { "Job" }
      sequence(:contact_email) { |n| "school#{n}@example.org" }
    end
  end
end
