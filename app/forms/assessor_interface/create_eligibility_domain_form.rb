# frozen_string_literal: true

class AssessorInterface::CreateEligibilityDomainForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :created_by
  attribute :domain, :string
  attribute :note, :string

  validates :domain, presence: true
  validates :domain, format: { with: /\A[A-Za-z0-9-]+[.][A-Za-z.]{2,}\z/ }

  validate :domain_uniqueness

  validates :created_by, :note, presence: true

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      eligibility_domain =
        EligibilityDomain.create!(domain: domain.downcase, created_by:)

      TimelineEvent.create!(
        eligibility_domain:,
        event_type: "eligibility_domain_created",
        creator: created_by,
        creator_name: created_by.name,
        note_text: note,
      )
    end
  end

  private

  def domain_uniqueness
    if EligibilityDomain.exists?(domain: domain&.downcase)
      errors.add(:domain, :uniqueness)
    end
  end
end
