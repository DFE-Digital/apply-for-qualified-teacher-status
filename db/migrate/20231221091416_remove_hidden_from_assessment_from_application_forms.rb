class RemoveHiddenFromAssessmentFromApplicationForms < ActiveRecord::Migration[
  7.1
]
  def change
    remove_column :application_forms,
                  :hidden_from_assessment,
                  :boolean,
                  default: false,
                  null: false
  end
end
