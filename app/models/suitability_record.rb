# frozen_string_literal: true

# == Schema Information
#
# Table name: suitability_records
#
#  id             :bigint           not null, primary key
#  archive_note   :text             default(""), not null
#  archived_at    :datetime
#  country_code   :text             default(""), not null
#  date_of_birth  :date
#  note           :text             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  archived_by_id :bigint
#  created_by_id  :bigint           not null
#
# Indexes
#
#  index_suitability_records_on_archived_by_id  (archived_by_id)
#  index_suitability_records_on_created_by_id   (created_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (archived_by_id => staff.id)
#  fk_rails_...  (created_by_id => staff.id)
#
class SuitabilityRecord < ApplicationRecord
  belongs_to :archived_by, class_name: "Staff", optional: true
  belongs_to :created_by, class_name: "Staff"
  has_and_belongs_to_many :application_forms
  has_many :emails, class_name: "SuitabilityRecord::Email"
  has_many :names, class_name: "SuitabilityRecord::Name"

  scope :active, -> { where(archived_at: nil) }

  validates :note, presence: true
  validates :archive_note, presence: true, if: :archived?

  def name
    names.min.value
  end

  def aliases
    names.map(&:value).sort - [name]
  end

  def status
    archived? ? "archived" : "active"
  end

  def archived?
    archived_at.present?
  end

  class Email < ApplicationRecord
    self.table_name = "suitability_record_emails"

    belongs_to :suitability_record

    validates :value, presence: true
    validates :canonical, presence: true

    before_validation { self.canonical = EmailAddress.canonical(value) }
  end

  class Name < ApplicationRecord
    self.table_name = "suitability_record_names"

    belongs_to :suitability_record

    validates :value, presence: true
  end
end
