class AddHiddenFromAssessmentToApplicationForms < ActiveRecord::Migration[7.1]
  def change
    add_column :application_forms,
               :hidden_from_assessment,
               :boolean,
               null: false,
               default: false
  end
end
