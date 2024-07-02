# frozen_string_literal: true

class AddPartOfUniversityDegreeToQualifications < ActiveRecord::Migration[7.0]
  def change
    add_column :qualifications, :part_of_university_degree, :boolean
  end
end
