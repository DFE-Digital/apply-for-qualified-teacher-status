# frozen_string_literal: true

class EligibilityInterface::QualificationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :eligibility_check
  attribute :qualification, :boolean

  validates :eligibility_check, presence: true
  validate :inclusion_of_qualification

  def save
    return false unless valid?

    eligibility_check.update!(qualification:)
  end

  private

  def inclusion_of_qualification
    unless [true, false].include?(qualification)
      errors.add(
        :qualification,
        :inclusion,
        country_name: CountryName.from_eligibility_check(eligibility_check),
      )
    end
  end
end
