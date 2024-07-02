# frozen_string_literal: true

class AddMailerClassNameToTimelineEvents < ActiveRecord::Migration[7.0]
  def up
    add_column :timeline_events,
               :mailer_class_name,
               :string,
               default: "",
               null: false

    TimelineEvent.email_sent.update_all(mailer_class_name: "TeacherMailer")
  end

  def down
    remove_column :timeline_events, :mailer_class_name
  end
end
