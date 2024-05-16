# frozen_string_literal: true

class Subject
  include ActiveModel::Model

  attr_accessor :value, :name, :ebacc
  alias_method :ebacc?, :ebacc

  class << self
    def all
      @all = find(ALL_VALUES)
    end

    def find(values)
      (ALL_VALUES & values).map { |value| create(value:) }
    end

    private

    def create(value:)
      Subject.new(
        value:,
        name: I18n.t("subjects.#{value}"),
        ebacc: EBACC_VALUES.include?(value),
      )
    end

    EBACC_VALUES = %w[
      ancient_hebrew
      applied_biology
      applied_chemistry
      applied_physics
      arabic_languages
      biology
      chemistry
      chinese_languages
      computer_science
      english_studies
      environmental_sciences
      french_language
      general_sciences
      geography
      german_language
      history
      italian_language
      latin_language
      materials_science
      mathematics
      modern_languages
      physics
      portuguese_language
      russian_languages
      spanish_language
      statistics
    ].freeze

    NON_EBACC_VALUES = %w[
      applied_computing
      art_and_design
      business_management
      business_studies
      child_development
      citizenship
      classical_greek_studies
      classical_studies
      construction_and_the_built_environment
      dance
      design
      design_and_technology
      drama
      early_years_teaching
      economics
      food_and_beverage_studies
      general_or_integrated_engineering
      graphic_design
      hair_and_beauty_sciences
      health_and_social_care
      health_studies
      historical_linguistics
      hospitality
      information_technology
      law
      manufacturing_engineering
      media_and_communication_studies
      music_education_and_teaching
      performing_arts
      philosophy
      physical_education
      primary_teaching
      product_design
      production_and_manufacturing_engineering
      psychology
      public_services
      recreation_and_leisure_studies
      religious_studies
      retail_management
      social_sciences
      specialist_teaching_primary_with_mathematics
      sport_and_exercise_sciences
      sports_management
      textiles_technology
      travel_and_tourism
      uk_government_parliamentary_studies
      welsh_language
    ].freeze

    ALL_VALUES = (EBACC_VALUES + NON_EBACC_VALUES).sort
  end
end
