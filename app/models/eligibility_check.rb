# == Schema Information
#
# Table name: eligibility_checks
#
#  id                     :bigint           not null, primary key
#  completed_at           :datetime
#  completed_requirements :boolean
#  country_code           :string
#  degree                 :boolean
#  free_of_sanctions      :boolean
#  qualification          :boolean
#  qualified_for_subject  :boolean
#  teach_children         :boolean
#  work_experience        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  region_id              :bigint
#
# Foreign Keys
#
#  fk_rails_...  (region_id => regions.id)
#
class EligibilityCheck < ApplicationRecord
  include Regulated

  belongs_to :region, optional: true
  has_one :application

  enum :work_experience,
       {
         under_9_months: "under_9_months",
         between_9_and_20_months: "between_9_and_20_months",
         over_20_months: "over_20_months",
       },
       prefix: true

  scope :complete, -> { where.not(completed_at: nil) }
  scope :eligible,
        -> {
          where.not(region: nil).where(
            degree: true,
            free_of_sanctions: true,
            qualification: true,
            teach_children: true,
          )
        }
  scope :ineligible,
        -> {
          where(degree: false)
            .or(where(free_of_sanctions: false))
            .or(where(qualification: false))
            .or(where(region: nil))
            .or(where(teach_children: false))
        }
  scope :answered_all_questions,
        -> {
          where.not(
            degree: nil,
            free_of_sanctions: nil,
            qualification: nil,
            teach_children: nil,
          )
        }

  delegate :country, to: :region, allow_nil: true

  def country_code=(value)
    super(value)
    regions =
      Region.joins(:country).where(
        country: {
          eligibility_enabled: true,
          code: value,
        },
      )
    self.region = regions.count == 1 ? regions.first : nil
  end

  def location
    CountryCode.to_location(country_code)
  end

  def england_or_wales?
    CountryCode.england?(country_code) || CountryCode.wales?(country_code)
  end

  def skip_additional_questions?
    country&.eligibility_skip_questions || false
  end

  def ineligible_reasons
    work_experience_ineligible = work_experience_under_9_months?

    qualified_for_subject_ineligible =
      qualified_for_subject_required? && qualified_for_subject == false

    teach_children_ineligible =
      !qualified_for_subject_required? && teach_children == false

    teach_children_secondary_ineligible =
      qualified_for_subject_required? && teach_children == false

    [
      (:country if region.nil?),
      (:qualification if qualification == false),
      (:degree if degree == false),
      (:teach_children if teach_children_ineligible),
      (:teach_children_secondary if teach_children_secondary_ineligible),
      (:qualified_for_subject if qualified_for_subject_ineligible),
      (:misconduct if free_of_sanctions == false),
      (:work_experience if work_experience_ineligible),
    ].compact
  end

  def eligible?
    if skip_additional_questions? && region.present? && qualification
      return true
    end

    region.present? && qualification && degree && teach_children? &&
      free_of_sanctions && !work_experience_under_9_months?
  end

  def teach_children?
    if qualified_for_subject_required?
      teach_children && qualified_for_subject
    else
      teach_children
    end
  end

  def country_eligibility_status
    if region
      :eligible
    elsif country_exists?
      :region
    else
      :ineligible
    end
  end

  def country_regions
    Region
      .joins(:country)
      .where(country: { eligibility_enabled: true, code: country_code })
      .order(:name)
  end

  def complete!
    touch(:completed_at)
  end

  def status
    if country_code.present? && country_eligibility_status == :ineligible
      return :eligibility
    end

    if skip_additional_questions? && region.present? && qualification
      return :eligibility
    end

    return :eligibility unless free_of_sanctions.nil?

    if qualified_for_subject_required? &&
         (teach_children == false || qualified_for_subject == false)
      return :eligibility
    end

    return :misconduct unless work_experience.nil?
    return :work_experience unless teach_children.nil?
    return :teach_children unless degree.nil?
    return :degree unless qualification.nil?
    return :qualification if region.present?
    return :region if country_code.present?

    :country
  end

  def qualified_for_subject_required?
    return false if region.blank?

    CountryCode.secondary_education_teaching_qualification_required?(
      region.country.code,
    )
  end

  private

  def country_exists?
    Country.where(eligibility_enabled: true).exists?(code: country_code)
  end
end
