# frozen_string_literal: true

class AssessorInterface::AssessmentDeclarationDeclineForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :assessment
  validates :assessment, presence: true

  attribute :declaration, :boolean
  attribute :recommendation_assessor_note, :string

  validates :declaration, presence: true
  validates :recommendation_assessor_note, presence: true, if: :note_required?

  def save
    return false unless valid?

    assessment.update!(
      recommendation_assessor_note: recommendation_assessor_note.presence || "",
    )

    true
  end

  def note_required?
    assessment.sections.all? { _1.selected_failure_reasons.empty? } ||
      assessment.further_information_requests.exists?(review_passed: false)
  end
end
