# frozen_string_literal: true

class RemoveEmailContentFromFurtherInformationRequests < ActiveRecord::Migration[
  7.0
]
  def change
    remove_column :further_information_requests, :email_content, :string
  end
end
