# frozen_string_literal: true

module TeacherInterface
  class QualificationForm < BaseForm
    include ActiveRecord::AttributeAssignment

    attr_accessor :qualification
    attribute :title, :string
    attribute :institution_name, :string
    attribute :institution_country_location, :string
    attribute :start_date
    attribute :complete_date
    attribute :certificate_date

    validates :qualification, presence: true
    validates :title, presence: true
    validates :institution_name, presence: true
    validates :institution_country_location, presence: true
    validates :start_date, date: true
    validates :complete_date, date: true
    validates :certificate_date, date: true
    validates_with DateComparisonValidator, later_field: :complete_date

    def initialize(values)
      if (country_code = values.delete(:institution_country_code))
        values[:institution_country_location] = CountryCode.to_location(
          country_code,
        )
      end

      super(values)
    end

    def update_model
      qualification.update!(
        title:,
        institution_name:,
        institution_country_code:,
        start_date:,
        complete_date:,
        certificate_date:,
      )
    end

    private

    def institution_country_code
      CountryCode.from_location(institution_country_location)
    end
  end
end
