class AddExcludesSuitabilityAndConcernsQuestionToReferenceRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :reference_requests, :excludes_suitability_and_concerns_question, :boolean, default: false, null: false
  end
end
