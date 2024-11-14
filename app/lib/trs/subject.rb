# frozen_string_literal: true

class TRS::Subject
  class << self
    def for(value)
      # these three subjects are not coded by HESA so we've agreed these encodings with the TRS team
      return "999001" if value == "citizenship"
      return "999002" if value == "physical_education"
      return "999003" if value == "design_and_technology"

      MAPPING.invert.fetch(value)
    end

    # https://www.hesa.ac.uk/collection/c22053/xml/c22053/c22053codelists.xsd
    # https://www.hesa.ac.uk/collection/c22053/e/sbjca
    MAPPING = {
      "101117" => "ancient_hebrew",
      "100343" => "applied_biology",
      "101038" => "applied_chemistry",
      "100358" => "applied_computing",
      "101060" => "applied_physics",
      "101192" => "arabic_languages",
      "100346" => "biology",
      "100078" => "business_management",
      "100079" => "business_studies",
      "100417" => "chemistry",
      "100456" => "child_development",
      "101165" => "chinese_languages",
      "101126" => "classical_greek_studies",
      "100300" => "classical_studies",
      "100366" => "computer_science",
      "100150" => "construction_and_the_built_environment",
      "101361" => "art_and_design",
      "100068" => "dance",
      "100048" => "design",
      "100069" => "drama",
      "100510" => "early_years_teaching",
      "100450" => "economics",
      "100320" => "english_studies",
      "100381" => "environmental_sciences",
      "101017" => "food_and_beverage_studies",
      "100321" => "french_language",
      "100184" => "general_or_integrated_engineering",
      "100390" => "general_sciences",
      "100409" => "geography",
      "100323" => "german_language",
      "100061" => "graphic_design",
      "101373" => "hair_and_beauty_sciences",
      "100476" => "health_and_social_care",
      "100473" => "health_studies",
      "101410" => "historical_linguistics",
      "100302" => "history",
      "100891" => "hospitality",
      "100372" => "information_technology",
      "100326" => "italian_language",
      "101420" => "latin_language",
      "100485" => "law",
      "100202" => "manufacturing_engineering",
      "100225" => "materials_science",
      "100403" => "mathematics",
      "100444" => "media_and_communication_studies",
      "100329" => "modern_languages",
      "100642" => "music_education_and_teaching",
      "100071" => "performing_arts",
      "100337" => "philosophy",
      "100425" => "physics",
      "101142" => "portuguese_language",
      "100511" => "primary_teaching",
      "100050" => "product_design",
      "100209" => "production_and_manufacturing_engineering",
      "100497" => "psychology",
      "100091" => "public_services",
      "100893" => "recreation_and_leisure_studies",
      "100339" => "religious_studies",
      "100092" => "retail_management",
      "100330" => "russian_languages",
      "100471" => "social_sciences",
      "100332" => "spanish_language",
      "101085" => "specialist_teaching_primary_with_mathematics",
      "100433" => "sport_and_exercise_sciences",
      "100097" => "sports_management",
      "100406" => "statistics",
      "100214" => "textiles_technology",
      "100101" => "travel_and_tourism",
      "100610" => "uk_government_parliamentary_studies",
      "100333" => "welsh_language",
    }.freeze
  end
end
