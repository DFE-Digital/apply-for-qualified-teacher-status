# frozen_string_literal: true

class AssessorInterface::SuitabilityRecordForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment
  include SanitizeDates

  attr_accessor :suitability_record, :user
  validates :suitability_record, :user, presence: true

  attribute :aliases, array: true
  attribute :date_of_birth
  attribute :emails, array: true
  attribute :location
  attribute :name
  attribute :note
  attribute :references, array: true

  validates :date_of_birth, date: true
  validates :emails, valid_for_notify: true
  validates :location, presence: true
  validates :name, presence: true
  validates :note, presence: true

  def save
    return false if invalid?

    sanitize_dates!(date_of_birth)

    suitability_record.application_forms =
      ApplicationForm.where(reference: references)
    suitability_record.country_code = CountryCode.from_location(location)
    suitability_record.created_by = user if suitability_record.new_record?
    suitability_record.date_of_birth = date_of_birth
    suitability_record.emails =
      (emails.compact_blank || []).map do
        SuitabilityRecord::Email.new(value: _1)
      end
    suitability_record.names =
      names.compact_blank.map { SuitabilityRecord::Name.new(value: _1) }
    suitability_record.note = note

    suitability_record.save!

    true
  end

  private

  def names
    [name] + (aliases || [])
  end

  def validate_references
    unless ApplicationForm.where(reference: references).count ==
             references.count
      errors.add(:references, :inclusion)
    end
  end
end
