# frozen_string_literal: true

# == Schema Information
#
# Table name: qualification_requests
#
#  id               :bigint           not null, primary key
#  location_note    :text             default(""), not null
#  passed           :boolean
#  received_at      :datetime
#  reviewed_at      :datetime
#  state            :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  assessment_id    :bigint           not null
#  qualification_id :bigint           not null
#
# Indexes
#
#  index_qualification_requests_on_assessment_id     (assessment_id)
#  index_qualification_requests_on_qualification_id  (qualification_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#  fk_rails_...  (qualification_id => qualifications.id)
#
class QualificationRequest < ApplicationRecord
  include Requestable

  belongs_to :assessment
  belongs_to :qualification

  with_options if: :received? do
    validates :location_note, presence: true
  end

  def expires_after
    nil
  end
end
