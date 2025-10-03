# frozen_string_literal: true

# == Schema Information
#
# Table name: eligibility_domains
#
#  id                      :bigint           not null, primary key
#  application_forms_count :integer          default(0)
#  archived_at             :datetime
#  domain                  :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  created_by_id           :bigint           not null
#
# Indexes
#
#  index_eligibility_domains_on_created_by_id  (created_by_id)
#  index_eligibility_domains_on_domain         (domain) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => staff.id)
#
class EligibilityDomain < ApplicationRecord
  belongs_to :created_by, class_name: "Staff"

  has_many :timeline_events
  has_many :work_histories
  has_many :application_forms, -> { distinct }, through: :work_histories
end
