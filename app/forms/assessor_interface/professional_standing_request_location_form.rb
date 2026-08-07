# frozen_string_literal: true

class AssessorInterface::ProfessionalStandingRequestLocationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :requestable, :user
  validates :requestable, :user, presence: true

  attribute :received, :boolean
  validates :received, inclusion: [true]

  attribute :location_note, :string

  attribute :attachment
  validates :attachment,
            file_upload: true,
            presence: true,
            unless: -> { document.completed? }

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      create_upload! if attachment.present?

      if received && !requestable.received?
        ReceiveRequestable.call(requestable:, user:)
      end

      if requestable.requested? && requestable.reviewed?
        requestable.update!(review_passed: nil, reviewed_at: nil)
        ApplicationFormStatusUpdater.call(application_form:, user:)
      end

      requestable.update!(location_note: location_note.presence || "")
    end

    true
  end

  delegate :application_form, to: :requestable

  private

  def create_upload!
    document.uploads.each(&:destroy!)

    upload =
      document.uploads.create!(
        attachment: attachment,
        filename: attachment.original_filename,
        malware_scan_result: malware_scan_result(attachment),
        translation: false,
      )

    fetch_and_update_malware_scan_results(upload)
  end

  def document
    application_form&.written_statement_document
  end

  def fetch_and_update_malware_scan_results(upload)
    if FeatureFlags::FeatureFlag.active?(:fetch_malware_scan_result)
      UpdateMalwareScanResultJob.set(wait: 2.seconds).perform_later(upload)
    end
  end

  def malware_scan_result(attachment)
    if FeatureFlags::FeatureFlag.active?(:fetch_malware_scan_result)
      "pending"
    elsif attachment.original_filename == "virus.pdf"
      "suspect"
    else
      "clean"
    end
  end
end
