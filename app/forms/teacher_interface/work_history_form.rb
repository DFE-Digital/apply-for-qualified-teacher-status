# frozen_string_literal: true

module TeacherInterface
  class WorkHistoryForm < BaseForm
    include ActiveRecord::AttributeAssignment

    attr_accessor :work_history
    attribute :job, :string
    attribute :school_name, :string
    attribute :city, :string
    attribute :country_code, :string
    attribute :email, :string
    attribute :start_date, :date
    attribute :still_employed, :boolean
    attribute :end_date, :date

    validates :job, presence: true
    validates :school_name, presence: true
    validates :city, presence: true
    validates :country_code, presence: true
    validates :email, presence: true, valid_for_notify: true
    validates :start_date, presence: true
    validates :still_employed, inclusion: [true, false]
    validates :end_date, presence: true, unless: :still_employed

    def country_code=(value)
      super(CountryCode.from_location(value))
    end

    def update_model
      work_history.update!(
        job:,
        school_name:,
        city:,
        country_code:,
        email:,
        start_date:,
        still_employed:,
        end_date:,
      )
    end
  end
end
