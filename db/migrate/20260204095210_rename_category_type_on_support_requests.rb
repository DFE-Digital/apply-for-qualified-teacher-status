# frozen_string_literal: true

class RenameCategoryTypeOnSupportRequests < ActiveRecord::Migration[8.0]
  def change
    rename_column :support_requests, :category_type, :user_type
  end
end
