# frozen_string_literal: true

class AddMailerActionNameToTimelineEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :timeline_events,
               :mailer_action_name,
               :string,
               default: "",
               null: false
  end
end
