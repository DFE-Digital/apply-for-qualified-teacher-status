# frozen_string_literal: true

class AddEmailContentToFurtherInformationRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :further_information_requests, :email_content, :text
  end
end
