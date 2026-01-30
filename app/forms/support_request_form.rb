# frozen_string_literal: true

class SupportRequestForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :name, :string
  attribute :comment, :string
  attribute :category_type, :string
  attribute :application_enquiry_type, :string
  attribute :application_reference, :string

  validates :name, :email, :category_type, :comment, presence: true
  validates :application_reference,
            :application_enquiry_type,
            presence: true,
            if: :application_submitted_category?

  def save
    return false if invalid?

    support_request =
      SupportRequest.create!(
        email:,
        name:,
        comment:,
        category_type:,
        application_enquiry_type:,
        application_reference:,
      )

    CreateZendeskRequestJob.perform_later(support_request)

    true
  end

  private

  def application_submitted_category?
    category_type == "application_submitted"
  end
end
