# frozen_string_literal: true

class AddWithdrawnAtToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms, :withdrawn_at, :datetime
  end
end
