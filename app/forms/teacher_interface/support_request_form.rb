# frozen_string_literal: true

class TeacherInterface::SupportRequestForm < TeacherInterface::BaseForm
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

  def update_model
    SupportRequest.create!(
      email:,
      name:,
      comment:,
      category_type:,
      application_enquiry_type:,
      application_reference:,
    )

    Zendesk.create_ticket!(name:, email:, comment:)
  end

  private

  def application_submitted_category?
    category_type == "applicantion_submitted"
  end
end
