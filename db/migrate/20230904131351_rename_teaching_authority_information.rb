# frozen_string_literal: true

class RenameTeachingAuthorityInformation < ActiveRecord::Migration[7.0]
  def change
    change_table :countries, bulk: true do |t|
      t.rename :teaching_authority_other, :other_information
      t.rename :teaching_authority_status_information, :status_information
      t.rename :teaching_authority_sanction_information, :sanction_information
    end

    change_table :regions, bulk: true do |t|
      t.rename :teaching_authority_other, :other_information
      t.rename :teaching_authority_status_information, :status_information
      t.rename :teaching_authority_sanction_information, :sanction_information
    end
  end
end
