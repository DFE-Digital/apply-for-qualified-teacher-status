# == Schema Information
#
# Table name: assessment_sections
#
#  id                       :bigint           not null, primary key
#  checks                   :string           default([]), is an Array
#  failure_reasons          :string           default([]), is an Array
#  key                      :string           not null
#  passed                   :boolean
#  selected_failure_reasons :string           default([]), is an Array
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  assessment_id            :bigint           not null
#
# Indexes
#
#  index_assessment_sections_on_assessment_id          (assessment_id)
#  index_assessment_sections_on_assessment_id_and_key  (assessment_id,key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#
FactoryBot.define do
  factory :assessment_section do
    association :assessment

    trait :passed do
      passed { true }
    end

    trait :failed do
      passed { false }
    end
  end
end
