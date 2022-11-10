# == Schema Information
#
# Table name: further_information_requests
#
#  id             :bigint           not null, primary key
#  failure_reason :string           default(""), not null
#  passed         :boolean
#  received_at    :datetime
#  state          :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  assessment_id  :bigint
#
# Indexes
#
#  index_further_information_requests_on_assessment_id  (assessment_id)
#
class FurtherInformationRequest < ApplicationRecord
  belongs_to :assessment
  has_many :items,
           class_name: "FurtherInformationRequestItem",
           inverse_of: :further_information_request,
           dependent: :destroy

  enum :state,
       { requested: "requested", received: "received" },
       default: :requested

  def failed
    passed == false
  end
end
