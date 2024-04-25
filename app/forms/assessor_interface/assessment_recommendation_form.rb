# frozen_string_literal: true

class AssessorInterface::AssessmentRecommendationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :assessment
  validates :assessment, presence: true

  attribute :recommendation
  validates :recommendation,
            presence: true,
            inclusion: {
              in: ->(form) { form.assessment&.available_recommendations.to_a },
            }
end
