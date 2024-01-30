class AddQualificationsAssessorNoteToAssessment < ActiveRecord::Migration[7.1]
  def change
    add_column :assessments,
               :qualifications_assessor_note,
               :text,
               null: false,
               default: ""
  end
end
