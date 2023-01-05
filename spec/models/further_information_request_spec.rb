# frozen_string_literal: true

# == Schema Information
#
# Table name: further_information_requests
#
#  id                                      :bigint           not null, primary key
#  failure_assessor_note                   :string           default(""), not null
#  passed                                  :boolean
#  received_at                             :datetime
#  state                                   :string           not null
#  working_days_received_to_recommendation :integer
#  working_days_since_received             :integer
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  assessment_id                           :bigint           not null
#
# Indexes
#
#  index_further_information_requests_on_assessment_id  (assessment_id)
#
require "rails_helper"

RSpec.describe FurtherInformationRequest do
  describe "associations" do
    it { is_expected.to belong_to(:assessment) }
  end

  it do
    is_expected.to define_enum_for(:state).with_values(
      requested: "requested",
      received: "received",
      expired: "expired",
    ).backed_by_column_of_type(:string)
  end
end
