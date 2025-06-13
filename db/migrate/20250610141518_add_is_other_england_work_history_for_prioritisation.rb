# frozen_string_literal: true

class AddIsOtherEnglandWorkHistoryForPrioritisation < ActiveRecord::Migration[
  8.0
]
  def change
    add_column :work_histories,
               :is_other_england_educational_role,
               :boolean,
               null: false,
               default: false
  end
end
