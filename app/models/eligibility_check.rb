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
#  teach_children         :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  region_id              :bigint
#
# Foreign Keys
#
#  fk_rails_...  (region_id => regions.id)
#
class EligibilityCheck < ApplicationRecord
  include DfE::Analytics::Entities

  belongs_to :region, optional: true

  scope :complete, -> { where.not(completed_at: nil) }
  scope :eligible,
        -> {
          where
            .not(region: nil)
            .where(
              degree: true,
              free_of_sanctions: true,
              qualification: true,
              teach_children: true
            )
            .merge(
              where(completed_requirements: true).or(
                where.not(completed_requirements: true).merge(
                  _before_completed_requirements
                )
              )
            )
        }
  scope :ineligible,
        -> {
          where(degree: false)
            .or(where(free_of_sanctions: false))
            .or(where(qualification: false))
            .or(where(region: nil))
            .or(where(teach_children: false))
            .or(where(completed_requirements: false))
        }
  scope :answered_all_questions,
        -> {
          where.not(
            degree: nil,
            free_of_sanctions: nil,
            qualification: nil,
            teach_children: nil
          ).merge(
            where.not(completed_requirements: nil).or(
              where(completed_requirements: nil).merge(
                _before_completed_requirements
              )
            )
          )
        }

  # The completed requirements question was added after the eligibility
  # checker was launched.
  scope :_before_completed_requirements,
        -> { where(created_at: ..Date.new(2022, 7, 5)) }

  def country_code=(value)
    super(value)

    regions = Region.joins(:country).where(country: { code: value })
    self.region = regions.count == 1 ? regions.first : nil
  end

  def ineligible_reasons
    [
      !region ? :country : nil,
      !degree ? :degree : nil,
      !qualification ? :qualification : nil,
      !teach_children ? :teach_children : nil,
      !free_of_sanctions ? :misconduct : nil
    ].compact
  end

  def eligible?
    ineligible_reasons.empty?
  end

  def country_eligibility_status
    return region_eligibility_status if region
    Country.exists?(code: country_code) ? :region : :ineligible
  end

  def region_eligibility_status
    region.legacy ? :legacy : :eligible
  end

  def country_regions
    Region.joins(:country).where(country: { code: country_code }).order(:name)
  end

  def complete!
    touch(:completed_at)
  end

  def status
    # Ineligible and legacy countries aren't required to answer all the questions
    if (country_code.present? && country_eligibility_status == :ineligible) ||
         country_eligibility_status == :legacy
      return :eligibility
    end

    return :eligibility unless free_of_sanctions.nil?
    return :misconduct unless teach_children.nil?
    return :teach_children unless qualification.nil?
    return :qualification unless degree.nil?
    return :degree if region.present?
    return :region if country_code.present?

    :country
  end
end
