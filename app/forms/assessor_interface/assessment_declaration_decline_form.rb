# frozen_string_literal: true

class AssessorInterface::AssessmentDeclarationDeclineForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :assessment
  validates :assessment, presence: true

  attribute :declaration, :boolean
  attribute :recommendation_assessor_note, :string

  validates :declaration, presence: true
  validates :recommendation_assessor_note,
            presence: true,
            if: -> { assessment.selected_failure_reasons_empty? }

  def save
    return false unless valid?

    assessment.update!(
      recommendation_assessor_note: recommendation_assessor_note.presence || "",
    )

    true
  end
end
