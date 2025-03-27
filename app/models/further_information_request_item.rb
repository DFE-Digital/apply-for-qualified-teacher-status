# frozen_string_literal: true

# == Schema Information
#
# Table name: further_information_request_items
#
#  id                               :bigint           not null, primary key
#  contact_email                    :string
#  contact_job                      :string
#  contact_name                     :string
#  failure_reason_assessor_feedback :text
#  failure_reason_key               :string           default(""), not null
#  information_type                 :string
#  response                         :text
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  further_information_request_id   :bigint
#  work_history_id                  :bigint
#
# Indexes
#
#  index_fi_request_items_on_fi_request_id                     (further_information_request_id)
#  index_further_information_request_items_on_work_history_id  (work_history_id)
#
# Foreign Keys
#
#  fk_rails_...  (work_history_id => work_histories.id)
#
class FurtherInformationRequestItem < ApplicationRecord
  belongs_to :further_information_request, inverse_of: :items
  has_one :document, as: :documentable, dependent: :destroy
  has_one :assessment, through: :further_information_request
  has_one :application_form, through: :assessment
  belongs_to :work_history, optional: true

  enum :information_type,
       {
         text: "text",
         document: "document",
         work_history_contact: "work_history_contact",
       }

  def status
    if completed?
      "completed"
    elsif document? && document.any_unsafe_to_link?
      "error"
    else
      "not_started"
    end
  end

  def completed?
    (text? && response.present?) || (document? && document.completed?) ||
      (
        work_history_contact? && contact_name.present? &&
          contact_job.present? && contact_email.present? &&
          contact_email.match?(ValidForNotifyValidator::EMAIL_REGEX)
      )
  end

  def is_teaching?
    %w[teaching_certificate_illegible teaching_transcript_illegible].include?(
      failure_reason_key,
    )
  end

  def update_work_history_contact(user:)
    return unless work_history_contact?

    UpdateWorkHistoryContact.call(
      user:,
      work_history:,
      name: contact_name,
      job: contact_job,
      email: contact_email,
    )
  end

  def assessment_section
    assessment
      .sections
      .includes(:selected_failure_reasons)
      .find_by(selected_failure_reasons: { key: failure_reason_key })
  end
end
