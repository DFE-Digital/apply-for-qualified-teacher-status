# frozen_string_literal: true

class AddEligibilitySkipQuestionsToCountries < ActiveRecord::Migration[7.0]
  def change
    add_column :countries,
               :eligibility_skip_questions,
               :boolean,
               default: false,
               null: false
  end
end
