# frozen_string_literal: true

class AddAccessYourTeachingQualificationsUrlToTeachers < ActiveRecord::Migration[
  7.0
]
  def change
    add_column :teachers, :access_your_teaching_qualifications_url, :string
  end
end
