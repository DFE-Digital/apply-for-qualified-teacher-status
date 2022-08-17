# == Schema Information
#
# Table name: work_histories
#
#  id                  :bigint           not null, primary key
#  city                :text             default(""), not null
#  country_code        :text             default(""), not null
#  email               :text             default(""), not null
#  end_date            :date
#  job                 :text             default(""), not null
#  school_name         :text             default(""), not null
#  start_date          :date
#  still_employed      :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
#
# Indexes
#
#  index_work_histories_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
FactoryBot.define do
  factory :work_history do
    association :application_form

    trait :completed do
      school_name { "School" }
      city { "City" }
      country { "Country" }
      job { "Job" }
      email { "school@example.com" }
      start_date { Date.new(2020, 1, 1) }
      still_employed { true }
    end
  end
end
