# frozen_string_literal: true

# == Schema Information
#
# Table name: professional_standing_requests
#
#  id            :bigint           not null, primary key
#  location_note :text             default(""), not null
#  received_at   :datetime
#  state         :string           not null
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
class ProfessionalStandingRequest < ApplicationRecord
  include Requestable

  with_options if: :received? do
    validates :location_note, presence: true
  end
end
