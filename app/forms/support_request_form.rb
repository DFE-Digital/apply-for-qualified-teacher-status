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

    ActiveRecord::Base.transaction do
      SupportRequest.create!(
        email:,
        name:,
        comment:,
        category_type:,
        application_enquiry_type:,
        application_reference:,
      )

      Zendesk.create_ticket!(name:, email:, subject:, comment:)
    end

    true
  end

  private

  def application_submitted_category?
    category_type == "applicantion_submitted"
  end

  def application_not_submitted_category?
    category_type == "submitting_an_application"
  end

  def application_progress_update_enquiry?
    application_enquiry_type == "progress_update"
  end

  def subject
    if application_progress_update_enquiry? ||
         application_not_submitted_category?
      "[AfQTS Ops] Support request for #{name}"
    else
      "[AfQTS PR] Support request for #{name}"
    end
  end
end
