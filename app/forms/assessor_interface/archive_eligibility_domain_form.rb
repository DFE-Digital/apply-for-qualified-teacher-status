# frozen_string_literal: true

class AssessorInterface::ArchiveEligibilityDomainForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :archived_by, :eligibility_domain
  attribute :note, :string

  validates :archived_by, :note, presence: true

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      eligibility_domain.update!(archived_at: Time.current)

      TimelineEvent.create!(
        eligibility_domain:,
        event_type: "eligibility_domain_archived",
        creator: archived_by,
        creator_name: archived_by.name,
        note_text: note,
      )
    end
  end
end
