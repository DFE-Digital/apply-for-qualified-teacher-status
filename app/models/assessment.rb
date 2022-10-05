# == Schema Information
#
# Table name: assessments
#
#  id                  :bigint           not null, primary key
#  age_range_max       :integer
#  age_range_min       :integer
#  recommendation      :string           default("unknown"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  age_range_note_id   :bigint
#  application_form_id :bigint           not null
#
# Indexes
#
#  index_assessments_on_age_range_note_id    (age_range_note_id)
#  index_assessments_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (age_range_note_id => notes.id)
#  fk_rails_...  (application_form_id => application_forms.id)
#
class Assessment < ApplicationRecord
  belongs_to :application_form

  has_many :sections, class_name: "AssessmentSection"
  has_many :further_information_requests

  belongs_to :age_range_note, class_name: "Note", optional: true

  enum :recommendation,
       {
         unknown: "unknown",
         award: "award",
         decline: "decline",
         request_further_information: "request_further_information",
       },
       default: :unknown

  validates :recommendation,
            presence: true,
            inclusion: {
              in: recommendations.values,
            }

  def finished?
    sections_finished? && (award? || decline?)
  end

  def sections_finished?
    sections.none? { |section| section.state == :not_started }
  end

  def can_award?
    sections.all? { |section| section.state == :completed }
  end

  def can_decline?
    action_required?
  end

  def can_request_further_information?
    action_required? && !must_decline?
  end

  def available_recommendations
    [].tap do |recommendations|
      recommendations << "award" if can_award?
      if can_request_further_information?
        recommendations << "request_further_information"
      end
      recommendations << "decline" if can_decline?
    end
  end

  private

  def action_required?
    sections.any? { |section| section.state == :action_required }
  end

  def must_decline?
    sections.any?(&:declines_assessment?)
  end
end
