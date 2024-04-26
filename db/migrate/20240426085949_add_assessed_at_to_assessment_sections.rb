class AddAssessedAtToAssessmentSections < ActiveRecord::Migration[7.1]
  def change
    add_column :assessment_sections, :assessed_at, :datetime
  end
end
