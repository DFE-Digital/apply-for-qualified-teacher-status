# frozen_string_literal: true

# == Schema Information
#
# Table name: further_information_request_items
#
#  id                             :bigint           not null, primary key
#  assessor_notes                 :text
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

  enum :information_type, { text: "text", document: "document" }
end
