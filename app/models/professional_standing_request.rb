# frozen_string_literal: true

# == Schema Information
#
# Table name: professional_standing_requests
#
#  id                    :bigint           not null, primary key
#  expired_at            :datetime
#  failure_assessor_note :string           default(""), not null
#  location_note         :text             default(""), not null
#  passed                :boolean
#  ready_for_review      :boolean          default(FALSE), not null
#  received_at           :datetime
#  requested_at          :datetime
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

  def expires_after
    if application_form.teaching_authority_provides_written_statement
      36.weeks # 180 working days
    else
      6.weeks # 30 working days
    end
  end

  def after_received(*)
    if should_send_received_email?
      TeacherMailer.with(teacher:).professional_standing_received.deliver_later
    end
  end

  def after_expired(user:)
    if application_form.teaching_authority_provides_written_statement &&
         !application_form.withdrawn?
      DeclineQTS.call(application_form:, user:)
    end
  end

  delegate :teacher, to: :application_form

  private

  def should_send_received_email?
    !application_form.declined? &&
      application_form.teaching_authority_provides_written_statement
  end
end
