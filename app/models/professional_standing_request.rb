# frozen_string_literal: true

# == Schema Information
#
# Table name: professional_standing_requests
#
#  id                    :bigint           not null, primary key
#  failure_assessor_note :string           default(""), not null
#  location_note         :text             default(""), not null
#  passed                :boolean
#  received_at           :datetime
#  reviewed_at           :datetime
#  state                 :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  assessment_id         :bigint           not null
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
  include Locatable

  def expires_after
    18.weeks # 90 working days
  end

  def after_received(*)
    TeacherMailer.with(teacher:).professional_standing_received.deliver_later
  end

  def after_expired(user:)
    DeclineQTS.call(application_form:, user:)
  end

  delegate :teacher, to: :application_form
end
