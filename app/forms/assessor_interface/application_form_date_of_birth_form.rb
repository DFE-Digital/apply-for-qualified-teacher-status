# frozen_string_literal: true

class AssessorInterface::ApplicationFormDateOfBirthForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :application_form, :user
  attribute :date_of_birth

  validates :application_form, :user, presence: true
  validates :date_of_birth, date: true
  validate :date_of_birth_valid

  def save
    return false if invalid?

    UpdateApplicationFormPersonalInformation.call(
      application_form: application_form,
      user: user,
      date_of_birth: parsed_date_of_birth,
    )

    true
  end

  private

  def date_of_birth_valid
    return if parsed_date_of_birth.nil?

    if parsed_date_of_birth > 18.years.ago
      errors.add(:date_of_birth, :too_young)
    elsif parsed_date_of_birth < 100.years.ago
      errors.add(:date_of_birth, :too_old)
    end
  end

  def parsed_date_of_birth
    @parsed_date_of_birth ||= DateValidator.parse(date_of_birth)
  end
end
