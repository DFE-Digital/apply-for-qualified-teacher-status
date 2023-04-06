# frozen_string_literal: true

class AssessorInterface::AssessmentRecommendationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :assessment, :user
  attribute :recommendation, :string
  attribute :declaration, :boolean
  attribute :confirmation, :boolean

  validates :assessment, :user, :recommendation, presence: true
  validate :recommendation_allowed
  validates :declaration, presence: true, if: :needs_declaration?
  validates :confirmation,
            inclusion: {
              in: [true, false],
              message: ->(object, _) {
                I18n.t(
                  "assessor_interface.assessments.confirm.inclusion.#{object.recommendation}",
                )
              },
            },
            if: :needs_confirmation?

  def save
    return false unless valid?
    return true if needs_confirmation? && !confirmation

    UpdateAssessmentRecommendation.call(
      assessment:,
      user:,
      new_recommendation: recommendation,
    )
  end

  def award?
    recommendation == "award"
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

  def needs_preview?
    needs_declaration? && declaration
  end

  alias_method :needs_confirmation?, :needs_preview?
end
