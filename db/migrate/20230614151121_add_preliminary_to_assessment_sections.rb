# frozen_string_literal: true

class AddPreliminaryToAssessmentSections < ActiveRecord::Migration[7.0]
  def change
    add_column :assessment_sections,
               :preliminary,
               :boolean,
               null: false,
               default: false

    remove_index :assessment_sections, %i[assessment_id key], unique: true
    add_index :assessment_sections,
              %i[assessment_id preliminary key],
              unique: true,
              name: "index_assessment_sections_on_assessment_id_preliminary_key"
  end
end
