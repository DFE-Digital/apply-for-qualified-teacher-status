# == Schema Information
#
# Table name: regions
#
#  id                                            :bigint           not null, primary key
#  application_form_skip_work_history            :boolean          default(FALSE), not null
#  name                                          :string           default(""), not null
#  qualifications_information                    :text             default(""), not null
#  reduced_evidence_accepted                     :boolean          default(FALSE), not null
#  sanction_check                                :string           default("none"), not null
#  status_check                                  :string           default("none"), not null
#  teaching_authority_address                    :text             default(""), not null
#  teaching_authority_certificate                :text             default(""), not null
#  teaching_authority_emails                     :text             default([]), not null, is an Array
#  teaching_authority_name                       :text             default(""), not null
#  teaching_authority_online_checker_url         :string           default(""), not null
#  teaching_authority_other                      :text             default(""), not null
#  teaching_authority_provides_written_statement :boolean          default(FALSE), not null
#  teaching_authority_requires_submission_email  :boolean          default(FALSE), not null
#  teaching_authority_sanction_information       :string           default(""), not null
#  teaching_authority_status_information         :string           default(""), not null
#  teaching_authority_websites                   :text             default([]), not null, is an Array
#  written_statement_optional                    :boolean          default(FALSE), not null
#  created_at                                    :datetime         not null
#  updated_at                                    :datetime         not null
#  country_id                                    :bigint           not null
#
# Indexes
#
#  index_regions_on_country_id           (country_id)
#  index_regions_on_country_id_and_name  (country_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
FactoryBot.define do
  factory :region do
    association :country

    sequence(:name) { |n| "Region #{n}" }

    trait :national do
      name { "" }
    end

    trait :reduced_evidence_accepted do
      reduced_evidence_accepted { true }
    end

    trait :requires_preliminary_check do
      requires_preliminary_check { true }
    end

    trait :written_statement_optional do
      written_statement_optional { true }
    end

    trait :online_checks do
      sanction_check { :online }
      status_check { :online }
    end

    trait :written_checks do
      sanction_check { :written }
      status_check { :written }
    end

    trait :none_checks do
      sanction_check { :none }
      status_check { :none }
    end

    trait :with_teaching_authority do
      teaching_authority_address { Faker::Address.street_address }
      teaching_authority_emails { [Faker::Internet.email] }
      teaching_authority_websites { [Faker::Internet.url] }
    end

    trait :in_country do
      transient { country_code { "" } }
      country { Country.find_or_create_by(code: country_code) }
    end
  end
end
