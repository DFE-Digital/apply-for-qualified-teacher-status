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

    validate :start_date_valid
    validate :end_date_valid
    validate :end_date_is_after_start_date
    validates :job, presence: true
    validates :school_name, presence: true
    validates :city, presence: true
    validates :country_code, presence: true
    validates :contact_name, presence: true
    validates :contact_email, presence: true, valid_for_notify: true
    validates :still_employed, inclusion: [true, false]

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

    private

    def start_date_valid
      unless date_params_present?(start_date)
        errors.add(:start_date, :blank) && return
      end
      unless date_params_are_valid?(start_date)
        errors.add(:start_date, :invalid)
      end
      if date_params_are_valid?(start_date) &&
           as_date(start_date) >= Time.zone.now
        errors.add(:start_date, :future)
      end
    end

    def end_date_valid
      unless still_employed
        unless date_params_present?(end_date)
          errors.add(:end_date, :blank) && return
        end
        errors.add(:end_date, :invalid) unless date_params_are_valid?(end_date)
      end
    end

    def end_date_is_after_start_date
      if !still_employed && date_params_present?(start_date) &&
           date_params_present?(end_date) &&
           date_params_are_valid?(start_date) &&
           date_params_are_valid?(end_date) &&
           (as_date(end_date) <= as_date(start_date))
        errors.add(:end_date, :before_start_date)
      end
    end

    def date_params_are_valid?(date_hash)
      as_date(date_hash)
      true
    rescue Date::Error
      false
    end

    def as_date(date_hash)
      Date.new(date_hash[1], date_hash[2], date_hash[3])
    end

    def date_params_present?(date_hash)
      return false if date_hash.blank?

      date_hash.compact.length == 3
    end
  end
end
