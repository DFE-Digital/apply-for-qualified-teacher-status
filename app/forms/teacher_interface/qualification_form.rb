# frozen_string_literal: true

module TeacherInterface
  class QualificationForm < BaseForm
    include ActiveRecord::AttributeAssignment
    include SanitizeDates

    attr_accessor :qualification
    attribute :title, :string
    attribute :institution_name, :string
    attribute :institution_country_location, :string
    attribute :start_date
    attribute :complete_date
    attribute :certificate_date
    attribute :teaching_confirmation, :boolean

    validates :qualification, presence: true
    validates :title, presence: true
    validates :institution_name, presence: true
    validates :institution_country_location,
              presence: true,
              inclusion: {
                in: ->(form) do
                  [CountryCode.to_location(form.application_form.country.code)]
                end,
              },
              if: -> { qualification&.is_teaching? }
    validates :start_date, date: true
    validates :complete_date, date: true
    validates :certificate_date, date: true
    validates_with DateComparisonValidator, later_field: :complete_date
    validates_with DateComparisonValidator,
                   earlier_field: :complete_date,
                   later_field: :certificate_date,
                   allow_equal: true
    validates :teaching_confirmation,
              presence: true,
              if: -> { qualification&.is_teaching? }

    def initialize(values)
      if (country_code = values.delete(:institution_country_code))
        values[:institution_country_location] = CountryCode.to_location(
          country_code,
        )
      end

      super(values)
    end

    def update_model
      sanitize_dates!(start_date, complete_date, certificate_date)

      old_work_history_duration = create_work_history_duration

      qualification.update!(
        title:,
        institution_name:,
        institution_country_code:,
        start_date:,
        complete_date:,
        certificate_date:,
      )

      application_form.reload
      new_work_history_duration = create_work_history_duration

      if changed_work_history_duration?(
           old_work_history_duration,
           new_work_history_duration,
         )
        application_form.update!(
          qualification_changed_work_history_duration: true,
        )
      end
    end

    delegate :application_form, to: :qualification

    private

    def institution_country_code
      CountryCode.from_location(institution_country_location)
    end

    def create_work_history_duration
      WorkHistoryDuration.for_application_form(application_form).tap(
        &:count_months
      )
    end

    def changed_work_history_duration?(old_duration, new_duration)
      (
        old_duration.enough_for_submission? &&
          !new_duration.enough_for_submission?
      ) ||
        (
          old_duration.enough_to_skip_induction? &&
            !new_duration.enough_to_skip_induction?
        )
    end
  end
end
