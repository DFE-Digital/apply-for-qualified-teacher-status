# frozen_string_literal: true

class AssessorInterface::ReactivateEligibilityDomainForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :reactivated_by, :eligibility_domain
  attribute :note, :string

  validates :reactivated_by, :note, presence: true

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      eligibility_domain.update!(archived_at: nil)

      TimelineEvent.create!(
        eligibility_domain:,
        event_type: "eligibility_domain_reactivated",
        creator: reactivated_by,
        creator_name: reactivated_by.name,
        note_text: note,
      )
    end
  end
end
