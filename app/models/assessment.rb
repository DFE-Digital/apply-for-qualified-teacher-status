# == Schema Information
#
# Table name: assessments
#
#  id                                        :bigint           not null, primary key
#  age_range_max                             :integer
#  age_range_min                             :integer
#  age_range_note                            :text             default(""), not null
#  induction_required                        :boolean
#  qualifications_assessor_note              :text             default(""), not null
#  recommendation                            :string           default("unknown"), not null
#  recommendation_assessor_note              :text             default(""), not null
#  recommended_at                            :datetime
#  references_verified                       :boolean
#  scotland_full_registration                :boolean
#  started_at                                :datetime
#  subjects                                  :text             default([]), not null, is an Array
#  subjects_note                             :text             default(""), not null
#  unsigned_consent_document_generated       :boolean          default(FALSE), not null
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

  has_many :consent_requests, dependent: :destroy
  has_many :further_information_requests, dependent: :destroy
  has_one :professional_standing_request, dependent: :destroy, required: false
  has_many :qualification_requests, dependent: :destroy
  has_many :reference_requests, dependent: :destroy

  enum :recommendation,
       {
         award: "award",
         decline: "decline",
         request_further_information: "request_further_information",
         review: "review",
         unknown: "unknown",
         verify: "verify",
       }

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

  def review!
    update!(recommendation: "review", recommended_at: Time.zone.now)
  end

  def unknown!
    update!(recommendation: "unknown", recommended_at: nil)
  end

  def verify!
    update!(recommendation: "verify", recommended_at: Time.zone.now)
  end

  def completed?
    award? || decline?
  end

  def can_award?
    if application_form.created_under_new_regulations?
      return false if induction_required.nil?

      if verify?
        enough_reference_requests_verify_passed? &&
          all_consent_requests_verify_passed? &&
          all_qualification_requests_review_passed? &&
          professional_standing_request_verify_passed?
      elsif review?
        enough_reference_requests_review_passed? &&
          all_consent_requests_review_passed? &&
          all_qualification_requests_review_passed? &&
          professional_standing_request_review_passed?
      else
        false
      end
    else
      all_sections_or_further_information_requests_passed?
    end
  end

  def can_decline?
    if unknown?
      any_preliminary_section_failed? ||
        (all_sections_assessed? && any_section_failed? && any_section_declines?)
    elsif request_further_information?
      all_further_information_requests_reviewed? &&
        any_further_information_requests_failed?
    elsif review?
      return false unless all_consent_requests_reviewed?
      return false unless all_qualification_requests_reviewed?
      return false unless all_reference_requests_reviewed?
      return false unless professional_standing_request_reviewed?

      any_consent_requests_review_failed? ||
        any_qualification_requests_review_failed? ||
        any_reference_requests_review_failed? ||
        professional_standing_request_review_failed?
    else
      false
    end
  end

  def can_request_further_information?
    if unknown?
      all_sections_assessed? && any_section_failed? && no_section_declines?
    elsif request_further_information?
      further_information_requests.empty?
    else
      false
    end
  end

  def can_review?
    return false unless verify?
    return false unless application_form.created_under_new_regulations?

    return false unless all_consent_requests_verified?
    return false unless all_reference_requests_verified?
    return false unless professional_standing_request_verified?

    # We can skip qualifications if consent has been rejected
    return true if any_consent_requests_verify_failed?
    return false unless all_qualification_requests_verified?

    any_qualification_requests_verify_failed? ||
      any_reference_requests_verify_failed? ||
      professional_standing_request_verify_failed?
  end

  def can_verify?
    return false unless unknown? || request_further_information?
    return false unless application_form.created_under_new_regulations?

    all_sections_or_further_information_requests_passed?
  end

  def recommendable?
    can_award? || can_decline? || can_request_further_information? ||
      can_review? || can_verify?
  end

  def available_recommendations
    [].tap do |recommendations|
      recommendations << "award" if can_award?
      recommendations << "decline" if can_decline?
      if can_request_further_information?
        recommendations << "request_further_information"
      end
      recommendations << "review" if can_review?
      recommendations << "verify" if can_verify?
    end
  end

  def selected_failure_reasons_empty?
    sections.all? { |section| section.selected_failure_reasons.empty? }
  end

  def all_preliminary_sections_passed?
    sections.preliminary.all?(&:passed?)
  end

  def any_preliminary_section_failed?
    sections.preliminary.any?(&:failed?)
  end

  def any_not_preliminary_section_assessed?
    sections.not_preliminary.any?(&:assessed?)
  end

  def enough_reference_requests_verify_passed?
    return true if reference_requests.empty?
    return false if any_reference_requests_verify_failed?

    work_history_duration =
      WorkHistoryDuration.for_ids(
        reference_requests.where(verify_passed: true).pluck(:work_history_id),
        application_form:,
      )

    work_history_duration.enough_to_skip_induction? ||
      (
        reference_requests.all?(&:verified?) &&
          work_history_duration.enough_for_submission?
      )
  end

  private

  def all_sections_assessed?
    sections.all?(&:assessed?)
  end

  def all_sections_passed?
    sections.all?(&:passed?)
  end

  def any_section_failed?
    sections.any?(&:failed?)
  end

  def any_section_declines?
    sections.any?(&:declines_assessment?)
  end

  def no_section_declines?
    sections.none?(&:declines_assessment?)
  end

  def all_further_information_requests_reviewed?
    further_information_requests.present? &&
      further_information_requests.all?(&:reviewed?)
  end

  def all_further_information_requests_passed?
    further_information_requests.present? &&
      further_information_requests.all?(&:review_passed?)
  end

  def any_further_information_requests_failed?
    further_information_requests.any?(&:review_failed?)
  end

  def all_reference_requests_reviewed?
    reference_requests.where(verify_passed: false).all?(&:reviewed?)
  end

  def enough_reference_requests_review_passed?
    return true if reference_requests.empty?
    return false unless all_reference_requests_reviewed?

    WorkHistoryDuration.for_ids(
      reference_requests
        .where(review_passed: true)
        .or(reference_requests.where(verify_passed: true))
        .pluck(:work_history_id),
      application_form:,
    ).enough_for_submission?
  end

  def any_reference_requests_review_failed?
    reference_requests.any?(&:review_failed?)
  end

  def all_reference_requests_verified?
    reference_requests.all?(&:verified?)
  end

  def any_reference_requests_verify_failed?
    reference_requests.any?(&:verify_failed?)
  end

  def all_consent_requests_reviewed?
    consent_requests.where(verify_passed: false).all?(&:reviewed?)
  end

  def any_consent_requests_review_failed?
    consent_requests.any?(&:review_failed?)
  end

  def all_consent_requests_review_passed?
    consent_requests.all?(&:review_or_verify_passed?)
  end

  def all_consent_requests_verified?
    consent_requests.all?(&:verified?)
  end

  def any_consent_requests_verify_failed?
    consent_requests.any?(&:verify_failed?)
  end

  def all_consent_requests_verify_passed?
    consent_requests.all?(&:verify_passed?)
  end

  def all_qualification_requests_reviewed?
    qualification_requests.where(verify_passed: false).all?(&:reviewed?)
  end

  def all_qualification_requests_review_passed?
    if application_form.reduced_evidence_accepted
      qualification_requests.all? do |qualification_request|
        qualification_request.reviewed? || qualification_request.verified?
      end
    else
      qualification_requests.all?(&:review_or_verify_passed?)
    end
  end

  def any_qualification_requests_review_failed?
    qualification_requests.any?(&:review_failed?)
  end

  def all_qualification_requests_verified?
    qualification_requests.all?(&:verified?)
  end

  def all_qualification_requests_verify_passed?
    if application_form.reduced_evidence_accepted
      qualification_requests.all?(&:verified?)
    else
      qualification_requests.all?(&:verify_passed?)
    end
  end

  def any_qualification_requests_verify_failed?
    qualification_requests.any?(&:verify_failed?)
  end

  def professional_standing_request_reviewed?
    if professional_standing_request_part_of_verification?
      professional_standing_request.verify_passed? ||
        professional_standing_request.reviewed?
    else
      true
    end
  end

  def professional_standing_request_review_passed?
    if professional_standing_request_part_of_verification?
      professional_standing_request.review_or_verify_passed?
    else
      true
    end
  end

  def professional_standing_request_review_failed?
    professional_standing_request_part_of_verification? &&
      professional_standing_request.review_failed?
  end

  def professional_standing_request_verified?
    if professional_standing_request_part_of_verification?
      professional_standing_request.verified?
    else
      true
    end
  end

  def professional_standing_request_verify_passed?
    if professional_standing_request_part_of_verification?
      professional_standing_request.verify_passed?
    else
      true
    end
  end

  def professional_standing_request_verify_failed?
    professional_standing_request_part_of_verification? &&
      professional_standing_request.verify_failed?
  end

  def professional_standing_request_part_of_verification?
    !application_form.teaching_authority_provides_written_statement &&
      professional_standing_request.present?
  end

  def all_sections_or_further_information_requests_passed?
    (unknown? && all_sections_passed?) ||
      (request_further_information? && all_further_information_requests_passed?)
  end
end
