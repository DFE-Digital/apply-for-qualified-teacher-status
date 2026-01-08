# frozen_string_literal: true

class TeacherInterface::SupportRequestForm < TeacherInterface::BaseForm
  attribute :email, :string
  attribute :name, :string
  attribute :comment, :string
  attribute :category_type, :string
  attribute :application_enquiry_type, :string
  attribute :screenshot

  def update_model
    SupportRequest.create!(email:, name:, comment:, enquiry_type:, screenshot:)

    Zendesk.create_ticket!(name:, email:, comment:, attachments: [screenshot])
  end
end
