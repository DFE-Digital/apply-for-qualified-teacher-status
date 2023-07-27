# == Schema Information
#
# Table name: further_information_requests
#
#  id                                          :bigint           not null, primary key
#  failure_assessor_note                       :string           default(""), not null
#  passed                                      :boolean
#  received_at                                 :datetime
#  reviewed_at                                 :datetime
#  state                                       :string           not null
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

  scope :remindable, -> { requested }

  FOUR_WEEK_COUNTRY_CODES = %w[AU CA GI NZ US].freeze

  def should_send_reminder_email?(days_until_expired, number_of_reminders_sent)
    return true if days_until_expired <= 14 && number_of_reminders_sent.zero?

    return true if days_until_expired <= 7 && number_of_reminders_sent == 1

    return true if days_until_expired <= 2 && number_of_reminders_sent == 2

    false
  end

  def send_reminder_email(_number_of_reminders_sent)
    TeacherMailer
      .with(teacher:, further_information_request: self)
      .further_information_reminder
      .deliver_later
  end

  def expires_after
    if !application_form.created_under_new_regulations? &&
         FOUR_WEEK_COUNTRY_CODES.include?(application_form.country.code)
      4.weeks
    else
      6.weeks
    end
  end

  def after_received(*)
    TeacherMailer.with(teacher:).further_information_received.deliver_later
  end

  def after_expired(user:)
    DeclineQTS.call(application_form:, user:) unless application_form.withdrawn?
  end

  def after_reviewed(user:)
    # implement logic after this requestable has been reviewed
    items.each do |item|
      next unless item.work_history_contact?
      UpdateWorkHistoryContact.call(user:, 
                                    work_history: item.work_history, 
                                    name: item.contact_name, 
                                    job: item.contact_job,
                                    email: item.contact_email)
    end
  end

  delegate :teacher, to: :application_form
end
