# frozen_string_literal: true

# == Schema Information
#
# Table name: reference_requests
#
#  id                                         :bigint           not null, primary key
#  additional_information_response            :text             default(""), not null
#  children_comment                           :text             default(""), not null
#  children_response                          :boolean
#  contact_comment                            :text             default(""), not null
#  contact_job                                :string           default(""), not null
#  contact_name                               :string           default(""), not null
#  contact_response                           :boolean
#  dates_comment                              :text             default(""), not null
#  dates_response                             :boolean
#  excludes_suitability_and_concerns_question :boolean          default(FALSE), not null
#  expired_at                                 :datetime
#  hours_comment                              :text             default(""), not null
#  hours_response                             :boolean
#  lessons_comment                            :text             default(""), not null
#  lessons_response                           :boolean
#  misconduct_comment                         :text             default(""), not null
#  misconduct_response                        :boolean
#  received_at                                :datetime
#  reports_comment                            :text             default(""), not null
#  reports_response                           :boolean
#  requested_at                               :datetime
#  review_note                                :string           default(""), not null
#  review_passed                              :boolean
#  reviewed_at                                :datetime
#  satisfied_comment                          :text             default(""), not null
#  satisfied_response                         :boolean
#  slug                                       :string           not null
#  verified_at                                :datetime
#  verify_note                                :text             default(""), not null
#  verify_passed                              :boolean
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#  assessment_id                              :bigint           not null
#  work_history_id                            :bigint           not null
#
# Indexes
#
#  index_reference_requests_on_assessment_id    (assessment_id)
#  index_reference_requests_on_slug             (slug) UNIQUE
#  index_reference_requests_on_work_history_id  (work_history_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#  fk_rails_...  (work_history_id => work_histories.id)
#
class ReferenceRequest < ApplicationRecord
  include Remindable
  include Requestable

  has_secure_token :slug

  belongs_to :work_history

  scope :remindable,
        -> do
          where
            .not(requested_at: nil)
            .where(expired_at: nil, received_at: nil)
            .joins(assessment: :application_form)
            .merge(ApplicationForm.assessable)
        end

  scope :order_by_role, -> { order("work_histories.start_date": :desc) }
  scope :order_by_user, -> { order("work_histories.created_at": :asc) }

  with_options if: :received? do
    validates :contact_response, inclusion: [true, false]
    validates :dates_response, inclusion: [true, false]
    validates :hours_response, inclusion: [true, false]
    validates :children_response, inclusion: [true, false]
    validates :lessons_response, inclusion: [true, false]
    validates :reports_response, inclusion: [true, false]
    validates :misconduct_response, inclusion: [true, false]
    validates :satisfied_response, 
              inclusion: [true, false],
              unless: :excludes_suitability_and_concerns_question?
  end

  def responses_given?
    responses = [
      contact_response,
      dates_response,
      hours_response,
      children_response,
      lessons_response,
      reports_response,
      misconduct_response,
    ]

    responses << satisfied_response unless excludes_suitability_and_concerns_question?
    responses.none?(&:nil?)
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
      action: :reference_reminder,
      reference_request: self,
      number_of_reminders_sent:,
    )
  end

  def send_requested_email
    DeliverEmail.call(
      application_form:,
      mailer: RefereeMailer,
      action: :reference_requested,
      reference_request: self,
    )
  end

  def expires_after
    6.weeks
  end

  def after_requested(*)
    send_requested_email
  end

  def after_verified(*)
    UpdateAssessmentInductionRequired.call(assessment:)
  end

  def after_reviewed(*)
    UpdateAssessmentInductionRequired.call(assessment:)
  end
end
