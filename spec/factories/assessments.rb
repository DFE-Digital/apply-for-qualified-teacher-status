# == Schema Information
#
# Table name: assessments
#
#  id                  :bigint           not null, primary key
#  age_range_max       :integer
#  age_range_min       :integer
#  recommendation      :string           default("unknown"), not null
#  subjects            :text             default([]), not null, is an Array
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  age_range_note_id   :bigint
#  application_form_id :bigint           not null
#  subjects_note_id    :bigint
#
# Indexes
#
#  index_assessments_on_age_range_note_id    (age_range_note_id)
#  index_assessments_on_application_form_id  (application_form_id)
#  index_assessments_on_subjects_note_id     (subjects_note_id)
#
# Foreign Keys
#
#  fk_rails_...  (age_range_note_id => notes.id)
#  fk_rails_...  (application_form_id => application_forms.id)
#  fk_rails_...  (subjects_note_id => notes.id)
#
FactoryBot.define do
  factory :assessment do
    association :application_form
  end
end
