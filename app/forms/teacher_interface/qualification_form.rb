# frozen_string_literal: true

module TeacherInterface
  class QualificationForm < BaseForm
    include ActiveRecord::AttributeAssignment

    attr_accessor :qualification
    attribute :title, :string
    attribute :institution_name, :string
    attribute :institution_country_code, :string
    attribute :start_date
    attribute :complete_date
    attribute :certificate_date

    validates :qualification, presence: true
    validates :title, presence: true
    validates :institution_name, presence: true
    validates :institution_country_code, presence: true
    validates :start_date, date: true
    validates :complete_date, date: true
    validates :certificate_date, date: true
    validates_with DateComparisonValidator, later_field: :complete_date

    def institution_country_code=(value)
      super(CountryCode.from_location(value))
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
  end
end
