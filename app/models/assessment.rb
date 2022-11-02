# == Schema Information
#
# Table name: assessments
#
#  id                  :bigint           not null, primary key
#  age_range_max       :integer
#  age_range_min       :integer
#  recommendation      :string           default("unknown"), not null
#  recommended_at      :date
#  subjects            :text             default([]), not null, is an Array
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  age_range_note_id   :bigint
#  application_form_id :bigint           not null
#  subjects_note_id    :bigint
#
# Indexes
#
#  index_assessments_on_age_range_note_id    (age_range_note_id)
#  index_assessments_on_application_form_id  (application_form_id)
#  index_assessments_on_subjects_note_id     (subjects_note_id)
#
# Foreign Keys
#
#  fk_rails_...  (age_range_note_id => notes.id)
#  fk_rails_...  (application_form_id => application_forms.id)
#  fk_rails_...  (subjects_note_id => notes.id)
#
class Assessment < ApplicationRecord
  belongs_to :application_form

  has_many :sections, class_name: "AssessmentSection"
  has_many :further_information_requests

  belongs_to :age_range_note, class_name: "Note", optional: true
  belongs_to :subjects_note, class_name: "Note", optional: true

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
    sections_complete? || further_information_requests_passed?
  end

  def can_decline?
    sections_finished? && !can_award? && !can_request_further_information?
  end

  def can_request_further_information?
    action_required? && cannot_decline? && further_information_requests.empty?
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

  def sections_complete?
    sections.all? { |section| section.state == :completed }
  end

  def further_information_requests_passed?
    further_information_requests.present? &&
      further_information_requests.all?(&:passed)
  end

  def action_required?
    sections.any? { |section| section.state == :action_required }
  end

  def cannot_decline?
    sections.none?(&:declines_assessment?)
  end
end
