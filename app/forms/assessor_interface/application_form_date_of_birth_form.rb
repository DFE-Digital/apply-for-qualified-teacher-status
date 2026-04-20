# frozen_string_literal: true

class AssessorInterface::ApplicationFormDateOfBirthForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attr_accessor :application_form, :user
  attribute :date_of_birth, :date

  validates :application_form, :user, presence: true
  validates :date_of_birth, presence: true

  def save
    return false if invalid?

    UpdateApplicationFormPersonalInformation.call(
      application_form: application_form,
      user: user,
      date_of_birth: date_of_birth,
    )

    true
  end
end
