# frozen_string_literal: true

# == Schema Information
#
# Table name: prioritisation_reference_requests
#
#  id                                   :bigint           not null, primary key
#  confirm_applicant_comment            :text             default(""), not null
#  confirm_applicant_response           :boolean
#  contact_comment                      :text             default(""), not null
#  contact_response                     :boolean
#  expired_at                           :datetime
#  received_at                          :datetime
#  requested_at                         :datetime
#  review_note                          :text             default(""), not null
#  review_passed                        :boolean
#  reviewed_at                          :datetime
#  slug                                 :string           not null
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  assessment_id                        :bigint           not null
#  prioritisation_work_history_check_id :bigint           not null
#  work_history_id                      :bigint           not null
#
# Indexes
#
#  idx_on_prioritisation_work_history_check_id_179105c28e      (prioritisation_work_history_check_id)
#  index_prioritisation_reference_requests_on_assessment_id    (assessment_id)
#  index_prioritisation_reference_requests_on_slug             (slug) UNIQUE
#  index_prioritisation_reference_requests_on_work_history_id  (work_history_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#  fk_rails_...  (prioritisation_work_history_check_id => prioritisation_work_history_checks.id)
#  fk_rails_...  (work_history_id => work_histories.id)
#
class PrioritisationReferenceRequest < ApplicationRecord
  include Remindable
  include Requestable

  has_secure_token :slug

  belongs_to :work_history
  belongs_to :prioritisation_work_history_check

  scope :remindable,
        -> do
          where
            .not(requested_at: nil)
            .where(expired_at: nil, received_at: nil)
            .joins(assessment: :application_form)
            .merge(ApplicationForm.assessable)
        end

  with_options if: :received? do
    validates :contact_response, inclusion: [true, false]
    validates :confirm_applicant_response, inclusion: [true, false]
  end

  def responses_given?
    [contact_response, confirm_applicant_response].none?(&:nil?)
  end

  def should_send_reminder_email?(_name, number_of_reminders_sent)
    days_until_expired &&
      (
        (days_until_expired <= 28 && number_of_reminders_sent.zero?) ||
          (days_until_expired <= 14 && number_of_reminders_sent == 1)
      )
  end

  def send_reminder_email(_name, number_of_reminders_sent)
    DeliverEmail.call(
      application_form:,
      mailer: RefereeMailer,
      action: :prioritisation_reference_reminder,
      reference_request: self,
      number_of_reminders_sent:,
    )
  end

  def send_requested_email
    DeliverEmail.call(
      application_form:,
      mailer: RefereeMailer,
      action: :prioritisation_reference_requested,
      reference_request: self,
    )
  end

  def expires_after
    6.weeks
  end

  def after_requested(*)
    send_requested_email
  end
end
