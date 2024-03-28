# frozen_string_literal: true

class AssessorInterface::ApplicationFormEmailForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :application_form, :user
  attribute :email, :string

  validates :application_form, :user, :email, presence: true
  validate :teacher_doesnt_already_exist

  def save
    return false if invalid?

    UpdateTeacherEmail.call(application_form:, user:, email:)

    true
  end

  def teacher_doesnt_already_exist
    return if email.blank?

    errors.add(:email, :inclusion) if Teacher.find_by_email(email).present?
  end
end
