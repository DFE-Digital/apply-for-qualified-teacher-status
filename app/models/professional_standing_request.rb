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
class ProfessionalStandingRequest < ApplicationRecord
  include Requestable

  def expires_after
    if application_form.teaching_authority_provides_written_statement
      36.weeks # 180 working days
    else
      6.weeks # 30 working days
    end
  end

  def after_requested(*)
    if should_send_emails?
      DeliverEmail.call(
        application_form:,
        mailer: TeacherMailer,
        action: :initial_checks_passed,
      )
    end
  end

  def after_received(*)
    if should_send_emails?
      DeliverEmail.call(
        application_form:,
        mailer: TeacherMailer,
        action: :professional_standing_received,
      )
    end
  end

  def after_expired(user:)
    if application_form.teaching_authority_provides_written_statement &&
         application_form.withdrawn_at.nil?
      DeclineQTS.call(application_form:, user:)
    end
  end

  delegate :teacher, to: :application_form

  private

  def should_send_emails?
    application_form.declined_at.nil? &&
      application_form.teaching_authority_provides_written_statement
  end
end
