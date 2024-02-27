class RemovePartOfUniversityDegreeFromQualifications < ActiveRecord::Migration[
  7.1
]
  def change
    remove_column :qualifications, :part_of_university_degree, :boolean
  end
end
