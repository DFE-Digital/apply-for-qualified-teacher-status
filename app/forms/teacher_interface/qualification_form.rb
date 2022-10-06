# frozen_string_literal: true

module TeacherInterface
  class QualificationForm < BaseForm
    include ActiveRecord::AttributeAssignment

    attr_accessor :qualification
    attribute :title, :string
    attribute :institution_name, :string
    attribute :institution_country_code, :string
    attribute :start_date, :date
    attribute :complete_date, :date
    attribute :certificate_date, :date

    validates :qualification, presence: true
    validates :title, presence: true
    validates :institution_name, presence: true
    validates :institution_country_code, presence: true
    validates :start_date, presence: true
    validates :complete_date, presence: true
    validates :start_date,
              comparison: {
                less_than: :complete_date,
              },
              if: -> { complete_date.present? }
    validates :complete_date,
              comparison: {
                greater_than: :start_date,
              },
              if: -> { start_date.present? }
    validates :certificate_date, presence: true

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
