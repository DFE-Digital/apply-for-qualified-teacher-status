# frozen_string_literal: true

# == Schema Information
#
# Table name: further_information_request_items
#
#  id                             :bigint           not null, primary key
#  assessor_notes                 :text
#  failure_reason                 :string           default(""), not null
#  information_type               :string
#  response                       :text
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  further_information_request_id :bigint
#
# Indexes
#
#  index_fi_request_items_on_fi_request_id  (further_information_request_id)
#
class FurtherInformationRequestItem < ApplicationRecord
  belongs_to :further_information_request, inverse_of: :items
  has_one :document, as: :documentable

  enum :information_type, { text: "text", document: "document" }

  def state
    completed? ? :completed : :not_started
  end

  def completed?
    (text? && response.present?) || (document? && document.uploaded?)
  end

  def is_teaching_qualification?
    %w[teaching_certificate_illegible teaching_transcript_illegible].include?(
      failure_reason,
    )
  end
end
