# frozen_string_literal: true

class AssessorInterface::ConfirmRecommendationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :assessment, :user
  attribute :recommendation, :string
  attribute :declaration, :boolean

  validates :assessment, :user, :recommendation, presence: true
  validates :declaration, presence: true, if: :needs_declaration?
  validate :recommendation_allowed

  def save
    return false unless valid?

    UpdateAssessmentRecommendation.call(
      assessment:,
      user:,
      new_recommendation: recommendation,
    )
  end

  def recommendation_allowed
    return if assessment.blank? || recommendation.blank?

    unless assessment.available_recommendations.include?(recommendation)
      errors.add(:recommendation, :inclusion)
    end
  end

  def needs_declaration?
    %w[award decline].include?(recommendation)
  end
end
