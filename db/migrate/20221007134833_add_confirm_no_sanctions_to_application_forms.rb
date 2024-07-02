# frozen_string_literal: true

class AddConfirmNoSanctionsToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms,
               :confirmed_no_sanctions,
               :boolean,
               default: false,
               nullable: false
  end
end
