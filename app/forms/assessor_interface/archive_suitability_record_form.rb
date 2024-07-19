# frozen_string_literal: true

class AssessorInterface::ArchiveSuitabilityRecordForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :suitability_record, :user
  validates :suitability_record, :user, presence: true

  attribute :note
  validates :note, presence: true

  def save
    return false if invalid?

    suitability_record.update!(
      archived_at: Time.zone.now,
      archived_by: user,
      archive_note: note,
    )

    true
  end
end
