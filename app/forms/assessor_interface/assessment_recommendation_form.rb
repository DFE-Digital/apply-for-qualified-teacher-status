# frozen_string_literal: true

class AssessorInterface::AssessmentRecommendationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :assessment
  attribute :recommendation, :string

  validates :assessment, :recommendation, presence: true
  validate :recommendation_allowed

  def recommendation_allowed
    return if assessment.blank? || recommendation.blank?

    unless assessment.available_recommendations.include?(recommendation)
      errors.add(:recommendation, :inclusion)
    end
  end
end
