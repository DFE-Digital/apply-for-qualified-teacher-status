# frozen_string_literal: true

class AssessorInterface::ApplicationFormNameForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :application_form, :user
  attribute :given_names, :string
  attribute :family_name, :string

  validates :application_form, :user, presence: true

  def save
    return false if invalid?

    UpdateApplicationFormName.call(
      application_form:,
      user:,
      given_names:,
      family_name:,
    )

    true
  end
end
