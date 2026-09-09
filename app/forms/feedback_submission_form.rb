# frozen_string_literal: true

class FeedbackSubmissionForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  MAX_COMMENT_CHARACTER_LIMIT = 2000

  attribute :application_status
  attribute :overall_experience
  attribute :comment

  validates :application_status, presence: true
  validates :overall_experience, presence: true
  validate :comment_within_character_limit

  def save
    return false if invalid?

    FeedbackSubmission.create!(
      application_status:,
      overall_experience:,
      comment:,
      submitted_at: Time.zone.now,
    )

    true
  end

  private

  def comment_within_character_limit
    return if comment.blank?

    if comment.gsub(/\r\n?/, "\n").length > MAX_COMMENT_CHARACTER_LIMIT
      errors.add(:comment, :too_long)
    end
  end
end
