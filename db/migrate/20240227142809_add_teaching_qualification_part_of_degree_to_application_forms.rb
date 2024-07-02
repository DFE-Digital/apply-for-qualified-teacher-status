# frozen_string_literal: true

class AddTeachingQualificationPartOfDegreeToApplicationForms < ActiveRecord::Migration[
  7.1
]
  def change
    add_column :application_forms,
               :teaching_qualification_part_of_degree,
               :boolean
  end
end
