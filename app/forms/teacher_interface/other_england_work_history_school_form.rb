# frozen_string_literal: true

module TeacherInterface
  class OtherEnglandWorkHistorySchoolForm < BaseForm
    include ActiveRecord::AttributeAssignment
    include SanitizeDates

    attr_accessor :work_history
    attribute :school_name, :string
    attribute :address_line1, :string
    attribute :address_line2, :string
    attribute :city, :string
    attribute :country_location, :string
    attribute :postcode, :string
    attribute :school_website, :string
    attribute :job, :string
    attribute :start_date
    attribute :still_employed, :boolean
    attribute :end_date

    validates :school_name, presence: true
    validates :address_line1, presence: true
    validates :city, presence: true
    validates :postcode, presence: true
    validates :country_location, presence: true, inclusion: ["country:GB-ENG"]
    validates :job, presence: true
    validates :start_date, date: true
    validates :still_employed, inclusion: [true, false]
    validates :end_date, date: true, if: -> { still_employed == false }
    validates_with DateComparisonValidator, if: -> { still_employed == false }

    validate :end_date_within_last_12_months, if: -> { still_employed == false }

    def initialize(values)
      if (country_code = values.delete(:country_code))
        values[:country_location] = CountryCode.to_location(country_code)
      end

      super(values)
    end

    def update_model
      sanitize_dates!(start_date, end_date)

      work_history.update!(
        school_name:,
        address_line1:,
        address_line2:,
        city:,
        country_code:,
        postcode:,
        school_website:,
        job:,
        start_date:,
        still_employed:,
        end_date: still_employed ? nil : end_date,
        is_other_england_educational_role: true,
      )
    end

    delegate :application_form, to: :work_history

    private

    def country_code
      CountryCode.from_location(country_location)
    end

    def end_date_within_last_12_months
      date = DateValidator.parse(end_date)

      if date.present? && date < 1.year.ago.beginning_of_month
        errors.add(:end_date, :over_12_months_ago)
      end
    end
  end
end
