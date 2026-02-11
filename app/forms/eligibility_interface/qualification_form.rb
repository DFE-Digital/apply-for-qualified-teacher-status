# frozen_string_literal: true

class EligibilityInterface::QualificationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :eligibility_check
  attribute :qualification, :boolean

  validates :eligibility_check, presence: true
  validate :qualification_inclusion_with_country

  def qualification_inclusion_with_country
    unless [true, false].include?(qualification)
      errors.add(
        :qualification,
        :inclusion,
        country_name: CountryName.from_eligibility_check(eligibility_check),
      )
    end
  end

  def save
    return false unless valid?

    eligibility_check.update!(qualification:)
  end
end
