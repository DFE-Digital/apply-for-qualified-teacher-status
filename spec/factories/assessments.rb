# == Schema Information
#
# Table name: assessments
#
#  id                  :bigint           not null, primary key
#  age_range_max       :integer
#  age_range_min       :integer
#  age_range_note      :text             default(""), not null
#  recommendation      :string           default("unknown"), not null
#  recommended_at      :date
#  started_at          :datetime
#  subjects            :text             default([]), not null, is an Array
#  subjects_note       :text             default(""), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
#
# Indexes
#
#  index_assessments_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
FactoryBot.define do
  factory :assessment do
    association :application_form

    trait :award do
      recommendation { "award" }
      recommended_at { Time.zone.now }
    end

    trait :with_further_information_request do
      after(:create) do |assessment, _evaluator|
        create(
          :further_information_request,
          :requested,
          :with_items,
          assessment:,
        )
      end
    end
  end
end
