# == Schema Information
#
# Table name: work_histories
#
#  id                      :bigint           not null, primary key
#  canonical_contact_email :text             default(""), not null
#  city                    :text             default(""), not null
#  contact_email           :text             default(""), not null
#  contact_email_domain    :text             default(""), not null
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
    application_form

    canonical_contact_email { EmailAddress.canonical(contact_email) }
    contact_email_domain { EmailAddress.new(contact_email).host_name }

    trait :completed do
      city { Faker::Address.city }
      contact_job { Faker::Job.title }
      contact_name { Faker::Name.name }
      hours_per_week { Faker::Number.between(from: 20, to: 40) }
      job { Faker::Job.title }
      school_name { Faker::Educator.primary_school }
      sequence :country_code, Country::CODES.cycle
      sequence(:contact_email) { |n| "school#{n}@example.org" }
      start_date { Faker::Date.between(from: 5.years.ago, to: 9.months.ago) }
      still_employed
    end

    trait :still_employed do
      still_employed { true }
    end

    trait :not_still_employed do
      end_date { Faker::Date.between(from: start_date, to: 3.months.ago) }
      still_employed { false }
    end
  end
end
