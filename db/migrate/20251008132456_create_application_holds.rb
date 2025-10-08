# frozen_string_literal: true

class CreateApplicationHolds < ActiveRecord::Migration[8.0]
  def change
    create_table :application_holds do |t|
      t.datetime :released_at

      t.string :reason
      t.string :reason_comment
      t.string :release_comment

      t.references :application_form, null: false, foreign_key: true

      t.timestamps
    end
  end
end
