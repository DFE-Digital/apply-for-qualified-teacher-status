# == Schema Information
#
# Table name: assessments
#
#  id                  :bigint           not null, primary key
#  age_range_max       :integer
#  age_range_min       :integer
#  recommendation      :string           default("unknown"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  age_range_note_id   :bigint
#  application_form_id :bigint           not null
#
# Indexes
#
#  index_assessments_on_age_range_note_id    (age_range_note_id)
#  index_assessments_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (age_range_note_id => notes.id)
#  fk_rails_...  (application_form_id => application_forms.id)
#
FactoryBot.define do
  factory :assessment do
    association :application_form
  end
end
