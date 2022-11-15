# frozen_string_literal: true

class Subject
  include ActiveModel::Model

  attr_accessor :id, :name

  class << self
    def all
      @all = find(ALL_IDS)
    end

    def find(ids)
      (ALL_IDS & ids).map { |id| create(id:) }
    end

    private

    def create(id:)
      Subject.new(id:, name: I18n.t("subjects.#{id}"))
    end

    ALL_IDS = %w[
      ancient_hebrew
      applied_biology
      applied_chemistry
      applied_computing
      applied_physics
      arabic_languages
      art_and_design
      biology
      business_management
      business_studies
      chemistry
      child_development
      chinese_languages
      citizenship
      classical_greek_studies
      classical_studies
      computer_science
      construction_and_the_built_environment
      dance
      design
      design_and_technology
      drama
      early_years_teaching
      economics
      english_studies
      environmental_sciences
      food_and_beverage_studies
      french_language
      general_or_integrated_engineering
      general_sciences
      geography
      german_language
      graphic_design
      hair_and_beauty_sciences
      health_and_social_care
      health_studies
      historical_linguistics
      history
      hospitality
      information_technology
      italian_language
      latin_language
      law
      manufacturing_engineering
      materials_science
      mathematics
      media_and_communication_studies
      modern_languages
      music_education_and_teaching
      performing_arts
      philosophy
      physical_education
      physics
      portuguese_language
      primary_teaching
      production_and_manufacturing_engineering
      product_design
      psychology
      public_services
      recreation_and_leisure_studies
      religious_studies
      retail_management
      russian_languages
      social_sciences
      spanish_language
      specialist_teaching_primary_with_mathematics
      sports_management
      sport_and_exercise_sciences
      statistics
      textiles_technology
      travel_and_tourism
      uk_government_parliamentary_studies
      welsh_language
    ].freeze
  end
end
