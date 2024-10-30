# frozen_string_literal: true

class AddGovOneEmailToTeacherRecord < ActiveRecord::Migration[7.2]
  def change
    add_column :teachers, :gov_one_email, :string
  end
end
