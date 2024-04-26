class AddAssessedAtToAssessmentSections < ActiveRecord::Migration[7.1]
  def change
    add_column :assessment_sections, :assessed_at, :datetime

    AssessmentSection
      .where.not(passed: nil)
      .update_all("assessed_at = updated_at")
  end
end
