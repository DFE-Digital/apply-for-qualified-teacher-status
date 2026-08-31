# frozen_string_literal: true

class FeedbackSubmissionForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :teacher, :application_form

  attribute :application_status
  attribute :overall_experience
  attribute :comment

  validates :application_status, presence: true
  validates :overall_experience, presence: true
  validates :comment, length: { maximum: 2000 }

  def save
    return false if invalid?

    FeedbackSubmission.create!(
      application_status:,
      overall_experience:,
      comment:,
      application_form:,
      teacher:,
    )

    true
  end
end
