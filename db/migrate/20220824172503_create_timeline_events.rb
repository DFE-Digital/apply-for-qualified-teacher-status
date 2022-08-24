class CreateTimelineEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :timeline_events do |t|
      t.string :event_type, null: false
      t.references :application_form, foreign_key: true
      t.string :annotation, null: true
      t.integer :staff_id, null:true
      t.timestamps
    end
  end
end
