# frozen_string_literal: true

class AddPostcodeToWorkHistory < ActiveRecord::Migration[8.0]
  def change
    add_column :work_histories, :postcode, :string
  end
end
