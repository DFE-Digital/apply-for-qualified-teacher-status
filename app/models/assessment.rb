# == Schema Information
#
# Table name: assessments
#
#  id                  :bigint           not null, primary key
#  recommendation      :string           default("unknown"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
#
# Indexes
#
#  index_assessments_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
class Assessment < ApplicationRecord
  belongs_to :application_form

  has_many :sections, class_name: "AssessmentSection"
  has_many :further_information_requests

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
    sections.any? { |section| section.state == :action_required }
  end

  alias_method :can_request_further_information?, :can_decline?

  def available_recommendations
    [].tap do |recommendations|
      recommendations << "award" if can_award?
      if can_request_further_information?
        recommendations << "request_further_information"
      end
      recommendations << "decline" if can_decline?
    end
  end
end
