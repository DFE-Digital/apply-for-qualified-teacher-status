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
#  references_verified                       :boolean
#  scotland_full_registration                :boolean
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
         award: "award",
         verify: "verify",
         decline: "decline",
         request_further_information: "request_further_information",
         unknown: "unknown",
       },
       default: :unknown

  validates :recommendation,
            presence: true,
            inclusion: {
              in: recommendations.values,
            }

  def unknown!
    update!(recommendation: "unknown", recommended_at: nil)
  end

  def award!
    update!(recommendation: "award", recommended_at: Time.zone.now)
  end

  def verify!
    update!(recommendation: "verify", recommended_at: Time.zone.now)
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

  def completed?
    award? || decline?
  end

  def can_award?
    if application_form.created_under_new_regulations?
      return false if induction_required.nil?

      if skip_verification?
        all_sections_or_further_information_requests_passed?
      else
        verify? && enough_reference_requests_review_passed? &&
          all_qualification_requests_review_passed? &&
          professional_standing_request_review_passed?
      end
    else
      all_sections_or_further_information_requests_passed?
    end
  end

  def can_verify?
    return false unless application_form.created_under_new_regulations?

    return false if skip_verification?

    all_sections_or_further_information_requests_passed?
  end

  def can_decline?
    if unknown?
      any_preliminary_section_failed? ||
        (all_sections_finished? && any_section_failed? && any_section_declines?)
    elsif request_further_information?
      any_further_information_request_failed?
    elsif verify?
      true # TODO: check the state of verification requests
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
    can_award? || can_verify? || can_decline? ||
      can_request_further_information?
  end

  def available_recommendations
    [].tap do |recommendations|
      recommendations << "award" if can_award?
      recommendations << "verify" if can_verify?
      recommendations << "decline" if can_decline?
      if can_request_further_information?
        recommendations << "request_further_information"
      end
    end
  end

  def selected_failure_reasons_empty?
    sections.all? { |section| section.selected_failure_reasons.empty? }
  end

  def all_preliminary_sections_passed?
    sections.preliminary.all?(&:passed)
  end

  def any_preliminary_section_failed?
    sections.preliminary.any?(&:failed)
  end

  def any_not_preliminary_section_finished?
    sections.not_preliminary.any?(&:finished?)
  end

  private

  def all_sections_finished?
    sections.all?(&:finished?)
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
      further_information_requests.all?(&:review_passed?)
  end

  def any_further_information_request_failed?
    further_information_requests.present? &&
      further_information_requests.any?(&:review_failed?)
  end

  def enough_reference_requests_review_passed?
    return false unless references_verified

    months_count =
      WorkHistoryDuration.new(
        work_history_relation:
          application_form.work_histories.where(
            id:
              reference_requests.where(review_passed: true).map(
                &:work_history_id
              ),
          ),
      ).count_months

    months_count >= 9
  end

  def all_qualification_requests_review_passed?
    if qualification_requests.present?
      qualification_requests.all?(&:review_passed?)
    else
      true
    end
  end

  def professional_standing_request_review_passed?
    if !application_form.teaching_authority_provides_written_statement &&
         professional_standing_request.present?
      professional_standing_request.review_passed?
    else
      true
    end
  end

  def skip_verification?
    !application_form.needs_work_history ||
      application_form.reduced_evidence_accepted
  end

  def all_sections_or_further_information_requests_passed?
    (unknown? && all_sections_passed?) ||
      (request_further_information? && all_further_information_requests_passed?)
  end
end
