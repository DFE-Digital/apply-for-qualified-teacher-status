# == Schema Information
#
# Table name: assessments
#
#  id                                        :bigint           not null, primary key
#  age_range_max                             :integer
#  age_range_min                             :integer
#  age_range_note                            :text             default(""), not null
#  induction_required                        :boolean
#  recommendation                            :string           default("unknown"), not null
#  recommendation_assessor_note              :text             default(""), not null
#  recommended_at                            :datetime
#  started_at                                :datetime
#  subjects                                  :text             default([]), not null, is an Array
#  subjects_note                             :text             default(""), not null
#  working_days_since_started                :integer
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
  has_one :professional_standing_request, dependent: :destroy, required: false
  has_many :reference_requests, dependent: :destroy
  has_many :qualification_requests, dependent: :destroy

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

  def award!
    update!(recommendation: "award", recommended_at: Time.zone.now)
  end

  def decline!
    update!(recommendation: "decline", recommended_at: Time.zone.now)
  end

  def request_further_information!
    update!(
      recommendation: "request_further_information",
      recommended_at: Time.zone.now,
    )
  end

  def started?
    any_section_finished?
  end

  def can_award?
    if unknown?
      all_sections_passed?
    elsif request_further_information?
      all_further_information_requests_passed?
    else
      false
    end
  end

  def can_decline?
    if unknown?
      sections_ready =
        if application_form.created_under_new_regulations?
          any_section_finished?
        else
          all_sections_finished?
        end

      (sections_ready && any_section_failed? && any_section_declines?) ||
        professional_standing_request&.requested? || false
    elsif request_further_information?
      any_further_information_request_failed?
    else
      false
    end
  end

  def can_request_further_information?
    if unknown?
      all_sections_finished? && any_section_failed? && no_section_declines?
    elsif request_further_information?
      further_information_requests.empty?
    else
      false
    end
  end

  def recommendable?
    can_award? || can_decline? || can_request_further_information?
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

  def selected_failure_reasons_empty?
    sections.all? { |section| section.selected_failure_reasons.empty? }
  end

  private

  def all_sections_finished?
    sections.all?(&:finished?)
  end

  def any_section_finished?
    sections.any?(&:finished?)
  end

  def all_sections_passed?
    sections.all?(&:passed)
  end

  def any_section_failed?
    sections.any?(&:failed)
  end

  def any_section_declines?
    sections.any?(&:declines_assessment?)
  end

  def no_section_declines?
    sections.none?(&:declines_assessment?)
  end

  def all_further_information_requests_passed?
    further_information_requests.present? &&
      further_information_requests.all?(&:passed)
  end

  def any_further_information_request_failed?
    further_information_requests.present? &&
      further_information_requests.any?(&:failed)
  end
end
