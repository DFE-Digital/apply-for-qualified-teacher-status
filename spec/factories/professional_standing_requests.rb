# frozen_string_literal: true

# == Schema Information
#
# Table name: professional_standing_requests
#
#  id            :bigint           not null, primary key
#  expired_at    :datetime
#  location_note :text             default(""), not null
#  received_at   :datetime
#  requested_at  :datetime
#  review_note   :string           default(""), not null
#  review_passed :boolean
#  reviewed_at   :datetime
#  verified_at   :datetime
#  verify_note   :text             default(""), not null
#  verify_passed :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assessment_id :bigint           not null
#
# Indexes
#
#  index_professional_standing_requests_on_assessment_id  (assessment_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#
FactoryBot.define do
  factory :professional_standing_request do
    assessment

    trait :with_location_note do
      location_note do
        if assessment.application_form.teaching_authority_provides_written_statement
          Faker::Lorem.sentence
        else
          ""
        end
      end
    end

    factory :requested_professional_standing_request, traits: %i[requested]
    factory :received_professional_standing_request,
            traits: %i[requested with_location_note received]
  end
end
