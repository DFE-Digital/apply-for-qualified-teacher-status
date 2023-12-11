class AddNoteTextToTimelineEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :timeline_events, :note_text, :text, default: "", null: false
  end
end
