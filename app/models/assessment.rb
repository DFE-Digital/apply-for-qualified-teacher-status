# == Schema Information
#
# Table name: assessments
#
#  id                                        :bigint           not null, primary key
#  age_range_max                             :integer
#  age_range_min                             :integer
#  age_range_note                            :text             default(""), not null
#  recommendation                            :string           default("unknown"), not null
#  recommended_at                            :date
#  started_at                                :datetime
#  subjects                                  :text             default([]), not null, is an Array
#  subjects_note                             :text             default(""), not null
#  working_days_started_to_recommendation    :integer
#  working_days_submission_to_recommendation :integer
#  working_days_submission_to_started        :integer
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  application_form_id                       :bigint           not null
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

  has_many :sections, class_name: "AssessmentSection", dependent: :destroy
  has_many :further_information_requests, dependent: :destroy

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

  scope :started, -> { where.not(started_at: nil) }
  scope :recommended, -> { where.not(recommended_at: nil) }

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
