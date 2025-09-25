# frozen_string_literal: true

class ChangeNullToTrueForApplicationFormsOnNotes < ActiveRecord::Migration[8.0]
  def change
    change_column_null :notes, :application_form_id, true
  end
end
