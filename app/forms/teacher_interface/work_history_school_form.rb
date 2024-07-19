# frozen_string_literal: true

module TeacherInterface
  class WorkHistorySchoolForm < BaseForm
    include ActiveRecord::AttributeAssignment
    include SanitizeDates

    attr_accessor :work_history
    attribute :meets_all_requirements, :boolean
    attribute :school_name, :string
    attribute :city, :string
    attribute :country_location, :string
    attribute :job, :string
    attribute :hours_per_week, :integer
    attribute :start_date
    attribute :start_date_is_estimate, :boolean
    attribute :still_employed, :boolean
    attribute :end_date
    attribute :end_date_is_estimate, :boolean

    validates :meets_all_requirements, presence: true
    validates :school_name, presence: true
    validates :city, presence: true
    validates :country_location, presence: true
    validates :job, presence: true
    validates :hours_per_week, presence: true
    validates :start_date, date: true
    validates :still_employed, inclusion: [true, false]
    validates :end_date, date: true, if: -> { still_employed == false }
    validates_with DateComparisonValidator, if: -> { still_employed == false }

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
        city:,
        country_code:,
        job:,
        hours_per_week:,
        start_date:,
        start_date_is_estimate: start_date_is_estimate || false,
        still_employed:,
        end_date: still_employed ? nil : end_date,
        end_date_is_estimate: end_date_is_estimate || false,
      )

      if application_form.qualification_changed_work_history_duration &&
           has_enough_work_history_for_submission?
        application_form.update!(
          qualification_changed_work_history_duration: false,
        )
      end
    end

    delegate :application_form, to: :work_history

    private

    def country_code
      CountryCode.from_location(country_location)
    end

    def has_enough_work_history_for_submission?
      WorkHistoryDuration.for_application_form(
        application_form.reload,
      ).enough_for_submission?
    end
  end
end
