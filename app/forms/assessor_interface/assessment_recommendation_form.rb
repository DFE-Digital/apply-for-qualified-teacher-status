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

  attribute :confirmation, :boolean
  validates :confirmation, presence: true, if: :requires_confirmation?

  def requires_confirmation?
    assessment&.can_verify? &&
      assessment&.application_form&.submitted_under_old_criteria?
  end
end
