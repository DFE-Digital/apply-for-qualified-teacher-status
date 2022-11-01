# frozen_string_literal: true

module TeacherInterface
  class WorkHistoryForm < BaseForm
    include ActiveRecord::AttributeAssignment

    attr_accessor :work_history
    attribute :job, :string
    attribute :school_name, :string
    attribute :city, :string
    attribute :country_code, :string
    attribute :contact_name, :string
    attribute :contact_email, :string
    attribute :start_date
    attribute :end_date
    attribute :still_employed, :boolean

    validates :job, presence: true
    validates :school_name, presence: true
    validates :city, presence: true
    validates :country_code, presence: true
    validates :contact_name, presence: true
    validates :contact_email, presence: true, valid_for_notify: true
    validates :start_date, date: true
    validates :end_date, date: true, unless: :still_employed
    validates :still_employed, inclusion: [true, false]
    validates_with DateComparisonValidator, unless: :still_employed

    def country_code=(value)
      super(CountryCode.from_location(value))
    end

    def update_model
      work_history.update!(
        job:,
        school_name:,
        city:,
        country_code:,
        contact_name:,
        contact_email:,
        start_date:,
        still_employed:,
        end_date:,
      )
    end
  end
end
