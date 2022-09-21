# == Schema Information
#
# Table name: notes
#
#  id                  :bigint           not null, primary key
#  text                :text             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
#  author_id           :bigint           not null
#
# Indexes
#
#  index_notes_on_application_form_id  (application_form_id)
#  index_notes_on_author_id            (author_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#  fk_rails_...  (author_id => staff.id)
#
FactoryBot.define do
  factory :note do
    association :application_form
    association :author, factory: :staff
    text { Faker::Lorem.paragraph }
  end
end
