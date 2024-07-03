# frozen_string_literal: true

class AddFilenameToUploads < ActiveRecord::Migration[7.1]
  def change
    add_column :uploads, :filename, :string, null: false, default: ""
  end
end
