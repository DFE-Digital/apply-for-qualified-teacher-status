# frozen_string_literal: true

class AddVerifierToApplicationForms < ActiveRecord::Migration[8.1]
  def change
    add_reference :application_forms,
                  :verifier,
                  foreign_key: {
                    to_table: :staff,
                  }
  end
end
