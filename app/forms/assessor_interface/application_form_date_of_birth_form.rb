# frozen_string_literal: true

class AssessorInterface::ApplicationFormDateOfBirthForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment
  include SanitizeDates

  attr_accessor :application_form, :user
  attribute :date_of_birth

  validates :application_form, :user, presence: true
  validates :date_of_birth, date: true
  validate :date_of_birth_valid

  def save
    return false if invalid?

    sanitize_dates!(date_of_birth)

    UpdateApplicationFormPersonalInformation.call(
      application_form: application_form,
      user: user,
      date_of_birth: date_of_birth,
    )

    true
  end

  private

  def date_of_birth_valid
    date = DateValidator.parse(date_of_birth)
    return if date.nil?

    if date > 18.years.ago
      errors.add(:date_of_birth, :too_young)
    elsif date < 100.years.ago
      errors.add(:date_of_birth, :too_old)
    end
  end
end
