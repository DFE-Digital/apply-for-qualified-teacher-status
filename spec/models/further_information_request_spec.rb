# frozen_string_literal: true

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
require "rails_helper"

RSpec.describe FurtherInformationRequest do
  subject(:further_information_request) { create(:further_information_request) }

  it_behaves_like "a remindable"
  it_behaves_like "a requestable"
end
