# frozen_string_literal: true

# == Schema Information
#
# Table name: further_information_requests
#
#  id                                          :bigint           not null, primary key
#  expired_at                                  :datetime
#  received_at                                 :datetime
#  requested_at                                :datetime
#  review_note                                 :string           default(""), not null
#  review_passed                               :boolean
#  reviewed_at                                 :datetime
#  working_days_assessment_started_to_creation :integer
#  working_days_received_to_recommendation     :integer
#  working_days_since_received                 :integer
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null
#  assessment_id                               :bigint           not null
#
# Indexes
#
#  index_further_information_requests_on_assessment_id  (assessment_id)
#
class FurtherInformationRequest < ApplicationRecord
  include Remindable
  include Requestable

  has_many :items,
           class_name: "FurtherInformationRequestItem",
           inverse_of: :further_information_request,
           dependent: :destroy

  scope :remindable,
        -> do
          where
            .not(requested_at: nil)
            .where(expired_at: nil, received_at: nil)
            .joins(assessment: :application_form)
            .merge(ApplicationForm.assessable)
        end

  FOUR_WEEK_COUNTRY_CODES = %w[AU CA GI NZ US].freeze

  def should_send_reminder_email?(_name, number_of_reminders_sent)
    days_until_expired &&
      (
        (days_until_expired <= 14 && number_of_reminders_sent.zero?) ||
          (days_until_expired <= 7 && number_of_reminders_sent == 1) ||
          (days_until_expired <= 2 && number_of_reminders_sent == 2)
      )
  end

  def send_reminder_email(_name, _number_of_reminders_sent)
    DeliverEmail.call(
      application_form:,
      mailer: TeacherMailer,
      action: :further_information_reminder,
      further_information_request: self,
    )
  end

  def expires_after
    if application_form.created_under_old_regulations? &&
         FOUR_WEEK_COUNTRY_CODES.include?(application_form.country.code)
      4.weeks
    else
      6.weeks
    end
  end

  def after_received(*)
    DeliverEmail.call(
      application_form:,
      mailer: TeacherMailer,
      action: :further_information_received,
    )
  end

  def after_expired(user:)
    if application_form.withdrawn_at.nil?
      DeclineQTS.call(application_form:, user:)
    end
  end

  def after_reviewed(user:)
    update_work_history_contact_items(user:)
  end

  def after_verified(user:)
    update_work_history_contact_items(user:)
  end

  def first_request?
    assessment
      .further_information_requests
      .order(:requested_at)
      .index(self)
      .zero?
  end

  def second_request?
    assessment.further_information_requests.order(:requested_at).index(self) ==
      1
  end

  def third_request?
    assessment.further_information_requests.order(:requested_at).index(self) ==
      2
  end

  delegate :teacher, to: :application_form

  private

  def update_work_history_contact_items(user:)
    items.each do |item|
      item.update_work_history_contact(user:) if item.review_decision_accept?
    end
  end
end
