# == Schema Information
#
# Table name: qualifications
#
#  id                        :bigint           not null, primary key
#  certificate_date          :date
#  complete_date             :date
#  institution_country_code  :text             default(""), not null
#  institution_name          :text             default(""), not null
#  part_of_university_degree :boolean
#  start_date                :date
#  title                     :text             default(""), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  application_form_id       :bigint           not null
#
# Indexes
#
#  index_qualifications_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
FactoryBot.define do
  factory :qualification do
    association :application_form

    trait :completed do
      title { Faker::Educator.degree }
      institution_name { Faker::University.name }
      sequence :institution_country_code, Country::CODES.cycle
      start_date { Date.new(2020, 1, 1) }
      complete_date { Date.new(2021, 1, 1) }
      certificate_date { Date.new(2021, 2, 1) }
      part_of_university_degree { true }

      after(:create) do |qualification, _evaluator|
        create(:upload, document: qualification.certificate_document)
        create(:upload, document: qualification.transcript_document)
      end
    end
  end
end
