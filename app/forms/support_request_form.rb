# frozen_string_literal: true

class SupportRequestForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :name, :string
  attribute :comment, :string
  attribute :user_type, :string
  attribute :application_enquiry_type, :string
  attribute :application_reference, :string

  validates :name, presence: true, max_string_length: true
  validates :email,
            presence: true,
            max_string_length: true,
            valid_for_notify: true
  validates :user_type, presence: true

  validates :application_reference,
            presence: true,
            max_string_length: true,
            if: :application_submitted_user?

  validates :application_enquiry_type,
            presence: true,
            if: :application_submitted_user?

  validates :comment,
            presence: true,
            max_text_length: true,
            length: {
              minimum: 30,
            }

  def save
    return false if invalid?

    support_request =
      SupportRequest.create!(
        email:,
        name:,
        comment:,
        user_type:,
        application_enquiry_type:,
        application_reference:,
      )

    CreateZendeskRequestJob.perform_later(support_request)

    true
  end

  private

  def application_submitted_user?
    user_type == "application_submitted"
  end
end
